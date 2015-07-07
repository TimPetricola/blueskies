module BlueSkies
  module Stemmer
    def self.stem(value, lang: :en)
      stemmer = Lingua::Stemmer.new(language: lang)
      stemmer.stem(
        I18n.transliterate(
          value
            .gsub('.', '')
            .gsub(' ', '')
            .gsub('-', '')
            .downcase
        )
      )
    end
  end
end
