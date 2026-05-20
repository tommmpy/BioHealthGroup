require "net/http"
require "json"

module Branches
  class Geocoder
    CACHE_EXPIRY = 7.days
    NOMINATIM_URL = "https://nominatim.openstreetmap.org/search"

    def self.coordinates_for(address)
      return nil if address.blank?

      clean = address.dup
        .gsub(/\(.*?\)/, "")
        .gsub(/\besq\.\s*/i, "")
        .gsub(/\s+y\s+/, ", ")
        .strip
        .gsub(/,+/, ",")
        .gsub(/^,|,$/, "")
        .strip

      query = "#{clean}, Uruguay"
      cache_key = "branch_coords/#{address.parameterize}"

      result = Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRY) do
        geocode(query) || fallback_geocode(clean)
      rescue StandardError => e
        Rails.logger.warn "Geocoding failed for #{address}: #{e.message}"
        nil
      end

      result
    end

    def self.geocode(query)
      uri = URI(NOMINATIM_URL)
      uri.query = URI.encode_www_form(q: query, format: "json", limit: "1")

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
    end

    def self.fallback_geocode(clean)
      parts = clean.split(",").map(&:strip).reject(&:blank?)
      return nil if parts.size <= 1

      geocode("#{parts.last}, Uruguay")
    end
  end
end