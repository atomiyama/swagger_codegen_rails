module SwaggerCodegenRails
  module Namespace

    def module_namespacing(&block)
      return unless namespaced?
      content = capture(&block)
      namespaces.reverse.each do |name|
        content = wrap_with_namespace(content, name)
      end
      concat(content)
    end

    def namespaced_route
      depth = 0
      lines = []

      namespaces.map(&:underscore).each do |ns|
        lines << indent("namespace :#{ns} do\n", depth*2)
        depth += 1
      end

      lines << indent("resources :swagger, only: :index\n", depth*2)

      until depth.zero?
        depth -= 1
        lines << indent("end\n", depth*2)
      end

      lines.join
    end
   
    def namespaces
      name.gsub('.','').split("/").reject(&:blank?).map(&:camelize)
    end

    def namespace
      File.join(name, "swagger").sub(/\A\//, '').sub(/\/\Z/, '')
    end

    def namespaced?
      namespaces
    end

    def wrap_with_namespace(content, namespace)
      content = indent(content).chomp
      "module #{namespace}\n#{content}\nend\n"
    end

    def indent(content, multiplier = 2)
      spaces = " " * multiplier
      content.each_line.map { |line| line.blank? ? line : "#{spaces}#{line}" }.join
    end
  end
end