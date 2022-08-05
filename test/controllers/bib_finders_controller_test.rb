# require 'test_helper'
#
# class BibFindersControllerTest < ActionController::TestCase
#   setup do
#     @bib_finder = bib_finders(:one)
#     @user = create(:user, staff: true, role: User::SUPER_USER_ROLE)
#     log_user_in(@user)
#   end
#
#   test "should get index" do
#     get :index
#     assert_response :success
#     assert_not_nil get_instance_var(:bib_finders)
#   end
#
#   test "should get new" do
#     get :new
#     assert_response :success
#   end
#
#   test "should create bib_finder" do
#     assert_difference('BibFinder.count') do
#       post :create, bib_finder: { config_solr: @bib_finder.config_solr, config_worldcat: @bib_finder.config_worldcat }
#     end
#
#     assert_redirected_to bib_finder_path(get_instance_var(:bib_finder))
#   end
#
#   test "should show bib_finder" do
#     get :show, id: @bib_finder
#     assert_response :success
#   end
#
#   test "should get edit" do
#     get :edit, id: @bib_finder
#     assert_response :success
#   end
#
#   test "should update bib_finder" do
#     patch :update, id: @bib_finder, bib_finder: { config_solr: @bib_finder.config_solr, config_worldcat: @bib_finder.config_worldcat }
#     assert_redirected_to bib_finder_path(get_instance_var(:bib_finder))
#   end
#
#   test "should destroy bib_finder" do
#     assert_difference('BibFinder.count', -1) do
#       delete :destroy, id: @bib_finder
#     end
#
#     assert_redirected_to bib_finders_path
#   end
# end
