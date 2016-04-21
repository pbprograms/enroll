class Notice

  attr_accessor :from, :to, :subject, :template, :notice_data, :mkt_kind, :file_name, :notice

  def initialize(args = {})
    random_str = rand(10**10).to_s
    @notice_filename = "notice_#{random_str}.pdf"
    @notice_path = Rails.root.join("tmp", @notice_filename)
    @envelope_path = Rails.root.join("tmp", "envelope_#{random_str}.pdf")
    @layout = 'pdf_notice'
  end

  def html(options = {})
    # notice_layout = 'bootstrap_email'
    # notice_layout = 'boiler_plate_email'
    ApplicationController.new.render_to_string({ 
      :template => @template,
      :layout => @layout,
      :locals => { notice: @notice }
    })
  end

  def pdf
    WickedPdf.new.pdf_from_string(
      self.html({kind: 'pdf'}),
      margin:  {  
        top: 15,
        bottom: 30,
        left: 22,
        right: 22 
        },
        disable_smart_shrinking: true,
        dpi: 96,
        page_size: 'Letter',
        formats: :html,
        encoding: 'utf8',
        # footer: { 
        #   content: ApplicationController.new.render_to_string({ 
        #     template: "notices/shared/footer.html.erb", 
        #     layout: false 
        #     })
        # })
        )
  end

  def send_email_notice
    ApplicationMailer.notice_email(self).deliver_now
  end

  def save_html
    File.open(Rails.root.join('pdfs','notice.html'), 'wb') do |file|
      file << self.html
    end
  end

  def generate_pdf_notice
    File.open(@notice_path, 'wb') do |file|
      file << self.pdf
    end

    doc_uri = upload_to_amazonS3
    notice = create_recipient_document(doc_uri)
    create_secure_inbox_message(notice)
    # clear_tmp
  end

  def upload_to_amazonS3
    Aws::S3Storage.save(@notice_path, 'notices')
  end

  def create_recipient_document(doc_uri)
    notice = @secure_message_recipient.documents.build({
      title: @notice_filename, 
      creator: "hbx_staff",
      subject: "notice",
      identifier: doc_uri,
      format: "application/pdf"
    })

    if notice.save
      notice
    else
      # LOG ERROR
    end
  end

  def create_secure_inbox_message(notice)
    subject = "New Notice Available"
    body = "<br>You can download the notice by clicking this link " +
            "<a href=" + "#{Rails.application.routes.url_helpers.authorized_document_download_path(@secure_message_recipient.class.to_s, @secure_message_recipient.id, 'documents', notice.id )}?content_type=#{notice.format}&filename=#{notice.title.gsub(/[^0-9a-z]/i,'')}.pdf&disposition=inline" + " target='_blank'>" + notice.title + "</a>"
    @secure_message_recipient.inbox.messages.build({
      subject: subject, body: body, from: 'DC Health Link'
    }).save!
  end

  def clear_tmp
    File.delete(@envelope_path)
    File.delete(@notice_path)
  end
end
