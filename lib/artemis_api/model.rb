module ArtemisApi
  class Model
    attr_reader :client, :id, :attributes, :relationships, :included

    class << self
      def related_to_one(name)
        register_relationship(name)

        send(:define_method, name.to_sym) do
          related_id = relationships.dig(name.to_s, 'data', 'id')
          included = client.get_record(name.to_s, related_id)

          return included if included&.present?

          relationship = relationships.dig(name.to_s, 'data')
          return if relationship.nil?

          @client.find_one(relationship['type'], relationship['id']) unless relationship['id'].to_s.empty? || relationship['id'].nil?
        end
      end

      def related_to_many(name)
        register_relationship(name)

        send(:define_method, name.to_sym) do
          included = relationships.dig(name.to_s, 'data')&.map do |related|
            client.get_record(name.to_s, related['id'])
          end

          return included if included&.present?

          @client.find_all(
            relationships.dig(name.to_s, 'data', 0, 'type') || name.to_s,
            filters: { name => id }
          )
        end
      end

      def json_type(type = nil)
        if type
          @json_type = type
          @@registered_classes ||= {}
          @@registered_classes[type] = self
        end
        @json_type
      end

      def instance_for(type, data, included, client)
        @@registered_classes[type]&.new(client, data, included)
      end

      def relationships
        @relationships ||= []
      end

      private

      def register_relationship(name)
        relationships << name.to_sym
      end
    end

    def method_missing(name)
      respond_to_missing?(name) ? attributes[name.to_s] : super
    end

    def respond_to_missing?(name)
      attributes.key?(name.to_s)
    end

    def initialize(client, data, included = nil)
      @client = client
      @id = data['id'].to_i
      @attributes = data['attributes']
      @relationships = data['relationships']
      @included = included
    end

    def inspect
      vars = %i[id attributes].map { |v| "#{v}=#{send(v).inspect}" }.join(', ')
      vars << ", relationships={#{self.class.relationships.join(', ')}}"
      "<#{self.class}: #{vars}>"
    end
  end
end
