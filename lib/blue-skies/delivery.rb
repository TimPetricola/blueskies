module BlueSkies
  class Delivery
    HTML_TEMPLATE = :digest_email_html
    TEXT_TEMPLATE = :digest_email_text

    def initialize(digest, sample: false, app_class: Routes::Base, unsubscribe: true)
      @digest = digest
      @recipient = digest.recipient
      @sample = sample

      @app_class = app_class
      @app = app_class.new!

      @unsubscribe = unsubscribe
    end

    def deliver(at: nil)
      params = {
        to: @recipient.email,
        from: ENV['SEND_FROM'],
        subject: 'Blue Skies Digest',
        text: text,
        html: html_inlined
      }

      params['h:List-Unsubscribe'] = "<#{unsubscribe_url}>" if @unsubscribe

      params['o:deliverytime'] = at.rfc2822 if at

      Nestful::Request.new(
        "https://api.mailgun.net/v3/#{ENV['MAILGUN_DOMAIN']}/messages",
        method: :post,
        auth_type: :basic,
        user: 'api',
        password: ENV['MAILGUN_KEY'],
        params: params
      ).execute
    end

    def html
      html ||= template(HTML_TEMPLATE)
    end

    def html_inlined
      Premailer.new(html, css: css_paths, with_html_string: true).to_inline_css
    end

    def text
      text ||= template(TEXT_TEMPLATE)
    end

    private

    def template_locals
      {
        digest: @digest,
        links: @digest.links,
        recipient: @recipient,
        unsubscribe_url: unsubscribe_url,
        browser_url: browser_url
      }
    end

    def unsubscribe_url
      return if !@unsubscribe || @sample
      ENV['DOMAIN'] + '/subscriptions/' + @recipient.token + '/unsubscribe'
    end

    def browser_url
       ENV['DOMAIN'] + '/digests/' + (@sample ? 'sample' : @digest.id)
    end

    def template(template)
      @app.erb(template, locals: template_locals, layout: false)
    end

    def css_paths
      Nokogiri::HTML(html).search('link[@rel=stylesheet]').map do |t|
        'public/' + t.attr('href')
      end
    end
  end
end
