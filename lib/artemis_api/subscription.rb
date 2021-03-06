module ArtemisApi
  class Subscription < ArtemisApi::Model
    json_type 'subscriptions'

    def self.find(id:, facility_id:, client:, include: nil, force: false)
      client.find_one(self.json_type, id, facility_id: facility_id, include: include, force: force)
    end

    def self.find_all(facility_id:, client:, include: nil)
      client.find_all(self.json_type, facility_id: facility_id, include: include)
    end

    def self.create(facility_id:, subject:, destination:, client:)
      client.auto_refresh!

      url = "#{client.options[:base_uri]}/api/v3/facilities/#{facility_id}/subscriptions"
      params = { body: { subscription: { subject: subject, destination: destination } } }

      response = client.oauth_token.post(url, params)

      response.status == 200 ? client.process_response(response, 'subscriptions') : false
    end

    def self.delete(id:, facility_id:, client:)
      client.auto_refresh!

      url = "#{client.options[:base_uri]}/api/v3/facilities/#{facility_id}/subscriptions/#{id}"

      response = client.oauth_token.delete(url)
      client.remove_record('subscriptions', id) if response.status == 204
    end
  end
end
