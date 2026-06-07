(in-package #:immortal-coil)

(defstruct dialog-bundle
  (id            "unknown" :type dialog-bundle-id)
  (name          "Unknown" :type string)
  (version       nil :type (option string))
  (description   nil :type (option string))
  (author        nil :type (option string))
  (origin        :bundled :type dialog-script-origin)
  (root          #P"" :type pathname)
  (asset-root    #P"" :type pathname)
  (script-paths  nil :type list)
  (dependencies  nil :type list)
  (manifest-path nil :type (option pathname)))
