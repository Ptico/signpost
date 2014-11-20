class Signpost
  module VERSION
    MAJOR = 0.freeze
    MINOR = 1.freeze
    PATCH = 0.freeze

    String = [MAJOR, MINOR, PATCH].join('.').freeze

    def self.to_s
      String
    end
  end
end
