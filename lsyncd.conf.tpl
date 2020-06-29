{{ $sources := split .Env.SOURCES ":" }}
{{ $destinations := split .Env.DESTINATIONS ":" }}
{{ $excludes_env := default .Env.EXCLUDES "" }}
{{ $excludes := split $excludes_env ":" }}
{{ $chown := default .Env.CHOWN "" }}
{{ $delay := default .Env.DELAY 1 }}

settings {
  nodaemon = true,
  inotifyMode = "{{ default .Env.INOTIFYMODE "CloseWrite or Modify" }}",
  maxDelays = {{ default .Env.MAXDELAYS "10" }}
}

{{ range $index, $element := $sources }}
sync {
  default.rsync,
  source = "{{ $element }}",
  target = "{{ index $destinations $index }}",
  {{ if $index }}init = false,{{end}}
  exclude = { {{ range $i, $exclude := $excludes }}{{ if $i }}, {{end}}"{{ $exclude }}"{{ end }} },
  delay = {{ $delay }},
  rsync = {
    {{ if $chown }}
    chown = "{{ $chown }}",
    owner = true,
    group = true,
    {{end}}
    temp_dir = "/tmp"
  }
}
{{ end }}
