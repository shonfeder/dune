type t =
  | Success
  | Error
  (** Following EX_TEMPFAIL from
      {{:https://man7.org/linux/man-pages/man3/sysexits.h.3head.html}
      sysexits.h(3head)} *)
  | Temp_fail
  | Signal

val all : t list
val info : t -> Cmdliner.Cmd.Exit.info
val code : t -> int
