open Import

module type Command_spec = sig
  val doc : string
  val prefix : string
  val command : Dune_pkg.Dev_tool.t -> unit Cmdliner.Cmd.t
end

module Subcommand (S : Command_spec) = struct
  let info = Cmd.info ~doc:S.doc S.prefix
  let group = Cmd.group info (List.map Dune_pkg.Dev_tool.all ~f:S.command)
end

module Exec = Subcommand (struct
    let doc = "Command group for running wrapped tools."
    let prefix = "exec"
    let command = Tools_common.exec_command
  end)

module Install = Subcommand (struct
    let doc = "Command group for installing wrapped tools."
    let prefix = "install"
    let command = Tools_common.install_command
  end)

module Which = Subcommand (struct
    let doc = "Command group for printing the path to wrapped tools."
    let prefix = "which"
    let command = Tools_common.which_command
  end)

let doc = "Command group for wrapped tools."
let info = Cmd.info ~doc "tools"

let group =
  Cmd.group info [ Exec.group; Install.group; Which.group; Tools_common.env_command ]
;;
