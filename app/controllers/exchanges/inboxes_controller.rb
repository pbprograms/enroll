class Exchanges::InboxesController < InboxesController
  def find_inbox_provider
    @inbox_provider = HbxProfile.all.first
    @inbox_provider_name = "System Admin"
  end

  def destroy
    @sent_box = true
    super
  end

  def show
    @sent_box = true
    super
  end

end
