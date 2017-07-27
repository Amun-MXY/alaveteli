# -*- encoding : utf-8 -*-
class AlaveteliLocalization
  class << self
    def set_locales(available_locales, default_locale)
      # fallback locale and available locales
      available_locales = available_locales.to_s.
                            split(/ /).map { |locale| canonicalize(locale) }
      FastGettext.
        default_available_locales = available_locales.map { |x| x.to_sym }
      I18n.available_locales = available_locales.map do |locale_name|
        to_hyphen(locale_name)
      end
      I18n.locale = I18n.default_locale = to_hyphen(default_locale)
      FastGettext.default_locale = canonicalize(default_locale)
      RoutingFilter::Conditionallyprependlocale.locales = available_locales
    end

    def set_default_locale(locale)
      I18n.default_locale = to_hyphen(locale)
      FastGettext.default_locale = canonicalize(locale)
    end

    def set_default_text_domain(name, repos)
      FastGettext.add_text_domain name, :type => :chain, :chain => repos
      FastGettext.default_text_domain = name
    end

    def set_default_locale_urls(include_default_locale_in_urls)
      RoutingFilter::Locale.include_default_locale = include_default_locale_in_urls
    end

    def locale
      FastGettext.locale.to_sym
    end

    def default_locale
      FastGettext.default_locale.to_sym
    end

    def default_locale?(other)
      return false if other.nil?
      default_locale == other.to_sym
    end

    def available_locales
      FastGettext.available_locales
    end

    private

    def canonicalize(locale)
      locale.to_s.gsub('-', '_')
    end

    def to_hyphen(locale)
      locale.to_s.gsub('_', '-')
    end
  end
end
