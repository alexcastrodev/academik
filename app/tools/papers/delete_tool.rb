# frozen_string_literal: true

module Papers
  class DeleteTool < MCP::Tool
    tool_name "paper-delete-tool"
    description "Delete a Paper entity of the given ID"
    annotations(
      read_only_hint: false,
      destructive_hint: true,
      idempotent_hint: true,
      open_world_hint: false
    )

    input_schema(
      properties: {
        id: { type: "integer" }
      },
      required: [ "id" ]
    )

    def self.call(id:, server_context:)
      paper = Paper.find(id)
      paper.destroy!
      MCP::Tool::Response.new([ { type: "text", text: "Paper of id = #{id} was deleted" } ])
    rescue ActiveRecord::RecordNotFound
      MCP::Tool::Response.new([ { type: "text", text: "Paper of id = #{id} was not found" } ])
    rescue StandardError => e
      MCP::Tool::Response.new([ { type: "text", text: "An error occurred: #{e.message}" } ])
    end
  end
end
