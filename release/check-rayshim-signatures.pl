#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename qw(dirname);
use Cwd qw(abs_path);

my $root = dirname(dirname(abs_path($0)));
my $claylib_dir = $ENV{IMMORTAL_COIL_CLAYLIB_DIR} || "$ENV{HOME}/quicklisp/local-projects/claylib";
my $source = $ARGV[0] || "$root/release/rayshim.c";

my %cffi_type_map = (
    ':bool' => 'bool',
    ':double' => 'double',
    ':float' => 'float',
    ':int' => 'int',
    ':long' => 'long',
    ':long-long' => 'long long',
    ':string' => 'char *',
    ':unsigned-char' => 'unsigned char',
    ':unsigned-int' => 'unsigned int',
    ':void' => 'void',
    'claylib/wrap::audio-callback' => 'AudioCallback',
    'claylib/wrap::audio-stream' => 'AudioStream',
    'claylib/wrap::bounding-box' => 'BoundingBox',
    'claylib/wrap::camera' => 'Camera',
    'claylib/wrap::camera-2d' => 'Camera2D',
    'claylib/wrap::camera-3d' => 'Camera3D',
    'claylib/wrap::color' => 'Color',
    'claylib/wrap::file-path-list' => 'FilePathList',
    'claylib/wrap::float16' => 'float16',
    'claylib/wrap::float3' => 'float3',
    'claylib/wrap::font' => 'Font',
    'claylib/wrap::glyph-info' => 'GlyphInfo',
    'claylib/wrap::image' => 'Image',
    'claylib/wrap::long-double' => 'long double',
    'claylib/wrap::material' => 'Material',
    'claylib/wrap::matrix' => 'Matrix',
    'claylib/wrap::mesh' => 'Mesh',
    'claylib/wrap::model' => 'Model',
    'claylib/wrap::model-animation' => 'ModelAnimation',
    'claylib/wrap::music' => 'Music',
    'claylib/wrap::n-patch-info' => 'NPatchInfo',
    'claylib/wrap::quaternion' => 'Quaternion',
    'claylib/wrap::ray' => 'Ray',
    'claylib/wrap::ray-collision' => 'RayCollision',
    'claylib/wrap::rectangle' => 'Rectangle',
    'claylib/wrap::render-texture-2d' => 'RenderTexture2D',
    'claylib/wrap::shader' => 'Shader',
    'claylib/wrap::sound' => 'Sound',
    'claylib/wrap::texture-2d' => 'Texture2D',
    'claylib/wrap::texture-cubemap' => 'TextureCubemap',
    'claylib/wrap::vector2' => 'Vector2',
    'claylib/wrap::vector3' => 'Vector3',
    'claylib/wrap::vector4' => 'Vector4',
    'claylib/wrap::vr-device-info' => 'VrDeviceInfo',
    'claylib/wrap::vr-stereo-config' => 'VrStereoConfig',
    'claylib/wrap::wave' => 'Wave',
);

sub slurp {
    my ($path) = @_;
    open my $fh, '<', $path or die "Could not read $path: $!\n";
    local $/;
    return <$fh>;
}

sub tokenize {
    my ($text) = @_;
    my @tokens;
    pos($text) = 0;
    while (pos($text) < length($text)) {
        if ($text =~ /\G\s+/gc) {
            next;
        } elsif ($text =~ /\G(;[^\n]*)/gc) {
            next;
        } elsif ($text =~ /\G([()])/gc) {
            push @tokens, $1;
        } elsif ($text =~ /\G"((?:\\.|[^"])*)"/gc) {
            push @tokens, $1;
        } elsif ($text =~ /\G([^\s()]+)/gc) {
            push @tokens, $1;
        } else {
            die "Could not tokenize near byte " . pos($text) . "\n";
        }
    }
    return @tokens;
}

sub parse_expr {
    my ($tokens, $index_ref) = @_;
    die "Unexpected end of tokens\n" if $$index_ref >= @$tokens;
    my $token = $tokens->[$$index_ref++];

    if ($token eq '(') {
        my @list;
        while ($$index_ref < @$tokens && $tokens->[$$index_ref] ne ')') {
            push @list, parse_expr($tokens, $index_ref);
        }
        die "Unclosed list\n" if $$index_ref >= @$tokens;
        $$index_ref++;
        return \@list;
    }

    die "Unexpected close paren\n" if $token eq ')';
    return $token;
}

sub parse_top_level_forms {
    my ($text) = @_;
    my @tokens = tokenize($text);
    my @forms;
    my $index = 0;
    while ($index < @tokens) {
        push @forms, parse_expr(\@tokens, \$index);
    }
    return @forms;
}

sub cffi_type_to_c {
    my ($type) = @_;

    if (ref($type) eq 'ARRAY') {
        die "Unsupported CFFI type form: " . sexp_to_string($type) . "\n"
            unless @$type == 2 && $type->[0] eq ':pointer';
        return normalize_c_type(cffi_type_to_c($type->[1]) . ' *');
    }

    die "Unsupported CFFI type atom: $type\n"
        unless exists $cffi_type_map{$type};
    return $cffi_type_map{$type};
}

sub normalize_c_type {
    my ($type) = @_;
    $type =~ s/^\s+|\s+$//g;
    $type =~ s/\s+/ /g;
    $type =~ s/\s*\*\s*/ */g;
    $type =~ s/\s+$//g;
    return $type;
}

sub strip_c_param_name {
    my ($param) = @_;
    $param =~ s/^\s+|\s+$//g;
    $param =~ s/\s*\*\s*/ * /g;
    $param =~ s/\s+/ /g;
    $param =~ s/\s+[A-Za-z_][A-Za-z0-9_]*$//;
    return normalize_c_type($param);
}

sub sexp_to_string {
    my ($expr) = @_;
    return $expr unless ref($expr) eq 'ARRAY';
    return '(' . join(' ', map { sexp_to_string($_) } @$expr) . ')';
}

sub signature_string {
    my ($return_type, $params) = @_;
    return $return_type . '(' . join(', ', @$params) . ')';
}

sub binding_signatures {
    my %signatures;
    my @bindings = sort glob("$claylib_dir/wrap/bindings/*.lisp");
    die "No Claylib binding files found under $claylib_dir/wrap/bindings\n"
        unless @bindings;

    for my $binding (@bindings) {
        for my $form (parse_top_level_forms(slurp($binding))) {
            next unless ref($form) eq 'ARRAY';
            next unless @$form >= 3 && $form->[0] eq 'cffi:defcfun';
            next unless ref($form->[1]) eq 'ARRAY' && $form->[1]->[0] =~ /__claw/;

            my $symbol = $form->[1]->[0];
            my $return_type = cffi_type_to_c($form->[2]);
            my @params = map {
                die "Malformed parameter for $symbol in $binding\n"
                    unless ref($_) eq 'ARRAY' && @$_ >= 2;
                cffi_type_to_c($_->[1]);
            } @$form[3 .. $#$form];
            my $signature = signature_string($return_type, \@params);

            if (exists $signatures{$symbol} && $signatures{$symbol} ne $signature) {
                die "$symbol has conflicting Claylib signatures:\n"
                    . "  $signatures{$symbol}\n"
                    . "  $signature\n";
            }
            $signatures{$symbol} = $signature;
        }
    }

    return %signatures;
}

sub source_signatures {
    my %signatures;
    my $text = slurp($source);

    while ($text =~ /^SHIM_EXPORT\s+(.+?)\s+(__claw[_A-Za-z0-9]*)\s*\(([^()]*)\)\s*\{/mg) {
        my ($return_type, $symbol, $params_text) = ($1, $2, $3);
        my @params;
        $return_type = normalize_c_type($return_type);

        if ($params_text =~ /\S/ && normalize_c_type($params_text) ne 'void') {
            for my $param (split /\s*,\s*/, $params_text) {
                push @params, strip_c_param_name($param);
            }
        }

        $signatures{$symbol} = signature_string($return_type, \@params);
    }

    return %signatures;
}

my %expected = binding_signatures();
my %actual = source_signatures();
my @errors;

for my $symbol (sort keys %expected) {
    if (!exists $actual{$symbol}) {
        push @errors, "Missing source signature for $symbol";
    } elsif ($actual{$symbol} ne $expected{$symbol}) {
        push @errors, "$symbol signature mismatch:\n"
            . "  Claylib: $expected{$symbol}\n"
            . "  rayshim: $actual{$symbol}";
    }
}

for my $symbol (sort keys %actual) {
    push @errors, "Unexpected source signature for $symbol"
        unless exists $expected{$symbol};
}

if (@errors) {
    print STDERR "release/rayshim.c signatures do not match Claylib's CFFI shim signatures.\n\n";
    print STDERR join("\n\n", @errors), "\n";
    exit 1;
}

print "rayshim signatures match Claylib CFFI shim bindings (" . scalar(keys %expected) . " symbols).\n";
