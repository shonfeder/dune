type t =
  | Success
  | Error
  | Temp_fail
  | Signal

let all = [ Success; Error; Temp_fail; Signal ]

let code = function
  | Success -> 0
  | Error -> 1
  | Temp_fail -> 75
  | Signal -> 130
;;

let doc = function
  | Success -> "on success."
  | Error -> "if an error happened."
  | Temp_fail -> "if the global lock was held by another instance of dune."
  | Signal -> "if it was interrupted by a signal."
;;

let info e = Cmdliner.Cmd.Exit.info (code e) ~doc:(doc e)
