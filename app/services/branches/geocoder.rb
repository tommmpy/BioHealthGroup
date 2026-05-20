require "net/http"
require "json"

module Branches
  class Geocoder
    CACHE_EXPIRY = 7.days
    NOMINATIM_URL = "https://nominatim.openstreetmap.org/search"

    def self.coordinates_for(address)
      return nil if address.blank?

      cache_key = "branch_coords/#{address.parameterize}"

      Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRY) do
        uri = URI(NOMINATIM_URL)
        uri.query = URI.encode_www_form(q: "#{address}, Uruguay", format: "json", limit: "1")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.open_timeout = 3
        http.read_timeout = 3

        request = Net::HTTP::Get.new(uri)
        request["User-Agent"] = "BioHealthGroup/1.0 (alveztomas2004@gmail.com)"
        request["Accept-Language"] = "es"

        response = http.request(request)

        if response.is_a?(Net::HTTPOK)
          data = JSON.parse(response.body)
          if data.any?
            { lat: data[0]["lat"].to_f, lon: data[0]["lon"].to_f }
          end
        end
      rescue StandardError => e
        Rails.logger.warn "Geocoding failed for #{address}: #{e.message}"
        nil
      end
    end
  end
end
