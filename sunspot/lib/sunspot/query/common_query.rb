module Sunspot
  module Query #:nodoc:
    class CommonQuery
      def initialize(types)
        @scope = Scope.new
        @sort = SortComposite.new
        @components = [@scope, @sort]
        if types.length == 1
          @scope.add_restriction(TypeField.instance, Restriction::EqualTo, types.first)
        else
          @scope.add_restriction(TypeField.instance, Restriction::AnyOf, types)
        end
      end
      
      def solr_parameter_adjustment=(block)
        @parameter_adjustment = block
      end

      def add_sort(sort)
        @sort << sort
      end

      def add_field_facet(facet)
        @components << facet
        facet
      end

      def add_query_facet(facet)
        @components << facet
        facet
      end

      def paginate(page, per_page)
        if @pagination
          @pagination.page = page
          @pagination.per_page = per_page
        else
          @components << @pagination = Pagination.new(page, per_page)
        end
      end

      def to_params
        params = {}
        @components.each do |component|
          Sunspot::Util.deep_merge!(params, component.to_params)
        end
        @parameter_adjustment.call(params) if @parameter_adjustment
        params[:q] ||= '*:*'
        params
      end

      def [](key)
        to_params[key.to_sym]
      end

      def page
        @pagination.page if @pagination
      end

      def per_page
        @pagination.per_page if @pagination
      end
    end
  end
end