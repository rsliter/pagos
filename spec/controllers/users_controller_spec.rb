require 'spec_helper'

describe UsersController do
  describe "before filter" do
    it "redirects to root url if the current user cannot manage users" do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in FactoryGirl.create(:volunteer_user)

      get :edit
      response.should redirect_to root_url
    end

    it "redirects if there is no current user" do
      get :edit
      response.should redirect_to root_url
    end

    it "does not redirect to root url if the current user can manage users" do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in FactoryGirl.create(:administrator_user)

      get :edit
      response.should_not be_redirect
    end
  end

  describe "GET #edit" do
    it "displays the list of registered users" do
      user = FactoryGirl.create(:administrator_user)
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in user

      users = [user]
      User.stub(:all).and_return(users)
      users.stub_chain(:where, :first).and_return(user) # Disgusting stub for current_user

      get :edit
      assigns[:users].should == [user]
    end
  end

  describe "POST #update" do
    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in FactoryGirl.create(:administrator_user)
    end

    it "updates a user's role according to the parameters" do
      user = User.create(id: 1, first_name: "R", last_name: "S", email: "r@s.com", password: "1234567890", password_confirmation: "1234567890", role: nil)

      expect {
        post :update, { "user" => { "#{user.id}" => { "role" => "volunteer" } } }
      }.to change{user.reload.role}.to("volunteer")
    end

    it "redirects to the edit page" do
      post :update, "user"=>{}
      response.should redirect_to action: 'edit'
    end
  end
end
