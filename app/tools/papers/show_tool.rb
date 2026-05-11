# frozen_string_literal: true

module Papers
  class ShowTool < MCP::Tool
    tool_name "paper-show-tool"
    description "Show all information about a Paper of the given ID"
    annotations(
      read_only_hint: true,
      destructive_hint: false,
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
      MCP::Tool::Response.new([ { type: "text", text: paper.to_mcp_response } ])
    rescue ActiveRecord::RecordNotFound
      MCP::Tool::Response.new([ { type: "text", text: "Paper of id = #{id} was not found" } ])
    rescue StandardError => e
      MCP::Tool::Response.new([ { type: "text", text: "An error occurred: #{e.message}" } ])
    end
  end
end
