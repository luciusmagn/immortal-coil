import std/[asyncdispatch, asynchttpserver, os, strutils, uri]

type
  EditorConfig = object
    host: string
    port: Port
    root: string

const
  defaultHost = "127.0.0.1"
  defaultPort = 8080

var config: EditorConfig

proc usage() =
  echo """
Usage: immortal-coil-editor [--host HOST] [--port PORT] [--root PATH]

Environment:
  IMMORTAL_COIL_EDITOR_HOST  Bind address, default 127.0.0.1
  IMMORTAL_COIL_EDITOR_PORT  Port, default 8080
  IMMORTAL_COIL_EDITOR_ROOT  Repository root override
"""

proc validEditorRoot(root: string): bool =
  fileExists(root / "tools" / "dialog-editor" / "index.html") and
    fileExists(root / "game" / "opening.lisp")

proc findEditorRoot(): string =
  let envRoot = getEnv("IMMORTAL_COIL_EDITOR_ROOT")

  if envRoot.len > 0:
    if validEditorRoot(envRoot):
      return absolutePath(envRoot)
    quit "Invalid IMMORTAL_COIL_EDITOR_ROOT: " & envRoot, QuitFailure

  var dir = getCurrentDir()

  while true:
    if validEditorRoot(dir):
      return absolutePath(dir)

    let parent = parentDir(dir)
    if parent == dir:
      break
    dir = parent

  quit "Could not find Immortal Coil repository root. Run from the repo or pass --root.",
       QuitFailure

proc parsePort(value: string): Port =
  try:
    let number = parseInt(value)
    if number < 1 or number > 65535:
      quit "Port must be between 1 and 65535: " & value, QuitFailure
    Port(number)
  except ValueError:
    quit "Invalid port: " & value, QuitFailure

proc parseConfig(): EditorConfig =
  result.host = getEnv("IMMORTAL_COIL_EDITOR_HOST", defaultHost)
  result.port = parsePort(getEnv("IMMORTAL_COIL_EDITOR_PORT", $defaultPort))
  result.root = ""

  let args = commandLineParams()
  var index = 0

  proc optionValue(argument: string; name: string): string =
    let prefix = "--" & name & "="
    if argument.startsWith(prefix):
      return argument[prefix.len .. ^1]

    if index + 1 >= args.len:
      usage()
      quit "Missing value for --" & name, QuitFailure

    inc index
    args[index]

  while index < args.len:
    let argument = args[index]

    if argument == "-h" or argument == "--help":
      usage()
      quit QuitSuccess
    elif argument == "--host" or argument.startsWith("--host="):
      result.host = optionValue(argument, "host")
    elif argument == "--port" or argument.startsWith("--port="):
      result.port = parsePort(optionValue(argument, "port"))
    elif argument == "--root" or argument.startsWith("--root="):
      result.root = optionValue(argument, "root")
    else:
      usage()
      quit "Unknown argument: " & argument, QuitFailure

    inc index

  if result.root.len == 0:
    result.root = findEditorRoot()
  elif validEditorRoot(result.root):
    result.root = absolutePath(result.root)
  else:
    quit "Invalid editor root: " & result.root, QuitFailure

proc contentType(path: string): string =
  case splitFile(path).ext.toLowerAscii()
  of ".html":
    "text/html; charset=utf-8"
  of ".css":
    "text/css; charset=utf-8"
  of ".js", ".mjs":
    "text/javascript; charset=utf-8"
  of ".json":
    "application/json; charset=utf-8"
  of ".lisp", ".cl", ".txt", ".md", ".org":
    "text/plain; charset=utf-8"
  of ".png":
    "image/png"
  of ".jpg", ".jpeg":
    "image/jpeg"
  of ".wav":
    "audio/wav"
  of ".ogg":
    "audio/ogg"
  else:
    "application/octet-stream"

proc safeRelativePath(rawPath: string): string =
  var path = decodeUrl(rawPath)

  if path.len == 0:
    path = "/"

  if path == "/":
    return ""

  if path == "/tools/dialog-editor":
    path = "/tools/dialog-editor/"

  if path.endsWith("/"):
    path.add("index.html")

  if path[0] == '/':
    path = path[1 .. ^1]

  for part in path.split('/'):
    if part.len == 0 or part == "." or part == ".." or
        part.contains('\\') or part.contains('\0'):
      return ""

  path

proc fileForRequest(root: string; rawPath: string): string =
  let relative = safeRelativePath(rawPath)
  if relative.len == 0:
    return ""
  root / relative

proc respondRedirect(req: Request; location: string) {.async.} =
  await req.respond(Http302, "Found", newHttpHeaders({"Location": location}))

proc respondNotFound(req: Request) {.async.} =
  await req.respond(Http404, "not found")

proc respondForbidden(req: Request) {.async.} =
  await req.respond(Http403, "forbidden")

proc handleRequest(req: Request; root: string) {.async.} =
  if req.url.path == "/" or req.url.path == "/tools/dialog-editor":
    await req.respondRedirect("/tools/dialog-editor/")
    return

  let path = fileForRequest(root, req.url.path)
  if path.len == 0:
    await req.respondForbidden()
    return

  if not fileExists(path):
    await req.respondNotFound()
    return

  let headers = newHttpHeaders({"Content-Type": contentType(path)})
  await req.respond(Http200, readFile(path), headers)

when isMainModule:
  config = parseConfig()

  echo "Serving Immortal Coil dialog editor from ", config.root
  echo "Open http://", config.host, ":", int(config.port), "/tools/dialog-editor/"

  var server = newAsyncHttpServer()
  let root = config.root
  let callback = proc(req: Request): Future[void] {.async, gcsafe.} =
    {.cast(gcsafe).}:
      await handleRequest(req, root)
  waitFor server.serve(config.port, callback, address = config.host)
