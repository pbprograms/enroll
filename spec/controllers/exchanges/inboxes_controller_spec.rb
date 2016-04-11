require 'rails_helper'

RSpec.describe Exchanges::InboxesController do
  context "DELETE destroy" do
    before :each do
      allow(controller).to receive(:find_message)
      controller.instance_variable_set(:@message, message)
      allow(message).to receive(:update_attributes).and_return(true)
    end

    context "broker inbox as admin" do
      let(:admin_user) { FactoryGirl.create(:user, person: admin_person, roles: ["hbx_staff"]) }
      let(:admin_person) { FactoryGirl.create(:person, :with_hbx_staff_role) }
      let(:broker_user) { FactoryGirl.create(:user, person: broker_person) }
      let(:broker_person) { FactoryGirl.create(:person, :with_broker_role ) }
      let(:inbox) { FactoryGirl.create(:inbox, recipient: broker_person) }
      let(:message){ FactoryGirl.create(:message, inbox: inbox) }

      before :each do
        sign_in(admin_user)
      end

      # it "show action" do
      #   get :show, id: broker_person.id, message_id: message.id, user: 'admin', folder: 'inbox'
      #   expect(response).to have_http_status(:success)
      # end

      it "delete action" do
        xhr :delete, :destroy, id: broker_person.id, message_id: message.id, user: 'admin'
        expect(response).to redirect_to(broker_agencies_profile_path(user: "admin", folder: "inbox"))
      end

    end

    context "consumer inbox as admin" do
      let(:admin_user) { FactoryGirl.create(:user, person: admin_person, roles: ["hbx_staff"]) }
      let(:admin_person) { FactoryGirl.create(:person, :with_hbx_staff_role) }
      let(:insured_user) { FactoryGirl.create(:user, person: insured_person) }
      let(:insured_person) { FactoryGirl.create(:person, :with_consumer_role) }
      let(:inbox) { FactoryGirl.create(:inbox, recipient: insured_person) }
      let(:message){ FactoryGirl.create(:message, inbox: inbox) }

      before :each do
        sign_in(admin_user)
      end

      it "delete action" do
        xhr :delete, :destroy, id: insured_person.id, person_id: insured_person.id, message_id: message.id, insured: insured_person.id
        expect(response).to redirect_to(inbox_insured_families_path(insured_person.id, tab: "messages", folder: "inbox"))
      end

    end

    context "employess inbox as admin" do
      let(:admin_user) { FactoryGirl.create(:user, person: admin_person, roles: ["hbx_staff"]) }
      let(:admin_person) { FactoryGirl.create(:person, :with_hbx_staff_role) }
      let(:insured_user) { FactoryGirl.create(:user, person: insured_person) }
      let(:insured_person) { FactoryGirl.create(:person, :with_employee_role) }
      let(:inbox) { FactoryGirl.create(:inbox, recipient: insured_person) }
      let(:message){ FactoryGirl.create(:message, inbox: inbox) }

      before :each do
        sign_in(admin_user)
      end

      it "delete action" do
        xhr :delete, :destroy, id: insured_person.id, person_id: insured_person.id, message_id: message.id, insured: insured_person.id
        expect(response).to redirect_to(inbox_insured_families_path(insured_person.id, tab: "messages", folder: "inbox"))
      end

    end

    context "employer profile inbox as admin" do
      let(:admin_user) { FactoryGirl.create(:user, person: admin_person, roles: ["hbx_staff"]) }
      let(:admin_person) { FactoryGirl.create(:person, :with_hbx_staff_role) }
      let(:inbox) { FactoryGirl.create(:inbox, recipient: employer_profile) }
      let(:message){ FactoryGirl.create(:message, inbox: inbox) }
      let(:employer_profile){ FactoryGirl.create(:employer_profile )}

      before :each do
        sign_in(admin_user)
      end

      it "delete action" do
        xhr :delete, :destroy, id: employer_profile.id, message_id: message.id, employer_profile: employer_profile.id
        expect(response).to redirect_to(employers_employer_profile_path(employer_profile.id, :tab=>'inbox', :folder=>'inbox'))
      end

    end

    context "admin inbox" do
      let(:admin_user) { FactoryGirl.create(:user, person: admin_person, roles: ["hbx_staff"]) }
      let(:admin_person) { FactoryGirl.create(:person, :with_hbx_staff_role) }
      let(:inbox) { FactoryGirl.create(:inbox, recipient: hbx_profile) }
      let(:message){ FactoryGirl.create(:message, inbox: inbox) }
      let(:hbx_profile){ FactoryGirl.create(:hbx_profile) }

      before :each do
        sign_in(admin_user)
      end


      it "delete action" do
        xhr :delete, :destroy, id: hbx_profile.id, message_id: message.id
        expect(response).to redirect_to(exchanges_hbx_profiles_path(hbx_profile.id, tab: "inbox", folder: "inbox"))
      end

    end

  end

end
