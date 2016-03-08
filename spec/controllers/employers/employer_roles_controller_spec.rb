require 'rails_helper'


describe Employers::EmployerStaffRolesController do
  let(:employer_staff_role) {FactoryGirl.create(:employer_staff_role)}
  let(:employer_profile) {EmployerProfile.find(employer_staff_role.employer_profile_id)}
  let(:employer) {employer_staff_role.person}
  let(:user) {FactoryGirl.create(:user)}
  let(:new_admin) {FactoryGirl.create(:person)}
  before do
    user.person = employer  
  end

  describe 'POST create' do
  	context 'finds a matching person' do
    	before do
        sign_in(user)
        xhr :post, :create, first_name: new_admin.first_name, last_name: new_admin.last_name, dob: new_admin.dob.to_s, id: employer_profile.id.to_s, email: Forgery('email').address, format: :js 
      end

      it 'sets @status' do
        expect(assigns[:status]).to eq true
      end

      it 'has response code success' do
        expect(response).to have_http_status(302)
      end

      it 'returns a person' do
        expect(assigns[:result]).to be_instance_of Person
      end
    end

    context 'does not find a matching person' do
      before do
        sign_in(user)
        xhr :post, :create, first_name: 'Sam', last_name: new_admin.last_name, dob: new_admin.dob.to_s, id: employer_profile.id.to_s, email: Forgery('email').address
      end

      it 'sets @status' do
        expect(assigns[:status]).to eq false
      end

      it 'has response code success' do
        expect(response).to have_http_status(302)
      end

      it 'returns a message' do
        expect(assigns[:result]).to be_instance_of String
      end
    end

    context 'finds two matching persons' do
      before do
        Person.create(first_name: new_admin.first_name, last_name: new_admin.last_name, dob: new_admin.dob.to_s)
        sign_in(user)
        xhr :post, :create, first_name: new_admin.first_name, last_name: new_admin.last_name, dob: new_admin.dob.to_s, id: employer_profile.id.to_s, email: Forgery('email').address
      end

      it 'sets @status' do
        expect(assigns[:status]).to eq false
      end

      it 'has response code failure' do
        expect(response).to have_http_status(302)
      end

      it 'does not return a person' do
        expect(assigns[:result]).to be_instance_of String
      end
    
    end
  end

  describe 'DELETE destroy' do

    context 'successfully deactivate role' do
      before do
        sign_in(user)
        Person.add_employer_staff_role(new_admin.first_name, new_admin.last_name, new_admin.dob, Forgery('email').address, employer_profile)
        xhr :delete, :destroy, staff_id: new_admin.id.to_s,  id: employer_profile.id.to_s
      end
      it 'sets @success' do
        expect(assigns[:status]).to eq true
      end
      it 'sets @result' do
        expect(assigns[:result]).to be_instance_of String
      end
    end

    context 'fails to deactivate role due to bad person' do
      before do
        sign_in(user)
        Person.add_employer_staff_role(new_admin.first_name, new_admin.last_name, new_admin.dob, Forgery('email').address, employer_profile)
        xhr :delete, :destroy, staff_id: 77,  id: employer_profile.id.to_s

      end
      it 'sets @success' do
        expect(assigns[:status]).to eq false
      end
      it 'sets @result' do
        expect(assigns[:result]).to be_instance_of String
      end
    end

    context 'invalid employer_profile_id ' do
      before do
        sign_in(user)
        employer_profile_unmatched = FactoryGirl.create(:employer_profile)
        Person.add_employer_staff_role(new_admin.first_name, new_admin.last_name, new_admin.dob, Forgery('email').address, employer_profile)
        xhr :delete, :destroy, staff_id: new_admin.id.to_s,  id: employer_profile_unmatched.id.to_s

      end
      it 'redirects to new_employers_employer_profile_path' do
        expect(response).to redirect_to new_employers_employer_profile_path
      end

    end
  end
end
