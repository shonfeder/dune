open Import

let toolchains = Config.make_toggle ~name:"toolchains" ~default:Setup.toolchains
let lock_dev_tools = Config.make_toggle ~name:"lock_dev_tool" ~default:Setup.lock_dev_tool
let bin_dev_tools = Config.make_toggle ~name:"bin_dev_tools" ~default:Setup.bin_dev_tools

let portable_lock_dir =
  let of_string = function
    | "" -> Ok None
    | s -> Config.Toggle.of_string s |> Result.map ~f:Option.some
  in
  Config.make ~of_string ~name:"portable_lock_dir" ~default:None
;;

let use_portable_lock_dir dune_version =
  match Config.get portable_lock_dir with
  | Some `Enabled -> true
  | Some `Disabled -> false
  | None ->
    if Dune_lang.Syntax.Version.compare dune_version (3, 21) = Lt then false else true
;;
