# frozen_string_literal: true

module RenderMethods
  extend ActiveSupport::Concern

  private

    def render_resource_or_errors(resource, options = {})
      resource.try(:errors).present? ? render_errors(resource) : render_resource(resource, options)
    end

    def render_errors(resource)
      render json: { errors: resource.errors }, status: :unprocessable_entity
    end

    def render_resource(resource, options = {})
      render json: resource, root: :resource, **options
    end

    def render_resources(resources, options = {})
      page = params.fetch :page, 1
      per_page = params[:per_page]
      proc_resources = options.fetch :pagination, true ? resources.page(page).per(per_page) : resources
      if options[:post_process]
        proc_resources = self.send options[:post_process_function], proc_resources, **options[:post_process_data]
      end
      render_hash = { json: proc_resources, root: :resources }
      render_hash.merge each_serializer: options[:serializer] if options[:serializer]
      render render_hash
    end
end
