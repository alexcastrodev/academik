# frozen_string_literal: true

module Annotations
  class ShowTool < MCP::Tool
    tool_name "annotation-show-tool"
    description "Show all information about an Annotation of the given ID"
    annotations(read_only_hint: true, destructive_hint: false, idempotent_hint: true, open_world_hint: false)

    input_schema(properties: { id: { type: "integer" } }, required: [ "id" ])

    def self.call(id:, server_context:)
      MCP::Tool::Response.new([ { type: "text", text: Annotation.find(id).to_mcp_response } ])
    rescue ActiveRecord::RecordNotFound
      MCP::Tool::Response.new([ { type: "text", text: "Annotation of id = #{id} was not found" } ])
    rescue StandardError => e
      MCP::Tool::Response.new([ { type: "text", text: "An error occurred: #{e.message}" } ])
    end
  end
end
