require File.expand_path('../../test_helper', __FILE__)
require 'redmine_multiprojects_issue/issues_controller_patch.rb'
require 'redmine_multiprojects_issue/issue_patch.rb'

class IssuesTest < ActionController::IntegrationTest

  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :trackers,
           :projects_trackers,
           :enabled_modules,
           :issue_statuses,
           :issues,
           :enumerations,
           :custom_fields,
           :custom_values,
           :custom_fields_trackers

  # create an issue with multiple projects
  def test_create_issue_with_multiple_projects
    log_user('jsmith', 'jsmith')
    get 'projects/1/issues/new', :tracker_id => '1'
    assert_response :success
    assert_template 'issues/new'
    assert_select "p#projects_form", :count => 1

    post 'projects/1/issues', :tracker_id => "1",
         :issue => { :start_date => "2006-12-26",
                     :priority_id => "4",
                     :subject => "new multiproject test issue",
                     :category_id => "",
                     :description => "new issue",
                     :done_ratio => "0",
                     :due_date => "",
                     :assigned_to_id => "",
                     :project_ids => [2, 3, 4]
         },
         :custom_fields => {'2' => 'Value for field 2'}

    # find created issue
    issue = Issue.find_by_subject("new multiproject test issue")
    assert_kind_of Issue, issue

    # check redirection
    assert_redirected_to :controller => 'issues', :action => 'show', :id => issue
    follow_redirect!
    assert_equal issue, assigns(:issue)

    # check issue attributes
    assert_equal 'jsmith', issue.author.login
    assert_equal 1, issue.project.id
    assert_equal [2,3,4], issue.projects.collect(&:id)
  end

  # update an issue and set several projects
  def test_update_projects
    log_user('jsmith', 'jsmith')
    get 'issues/1/edit'
    assert_response :success
    assert_template 'issues/edit'
    assert_select "p#projects_form", :count => 1

    put 'issues/1', {:issue => { :project_ids => [2, 3, 4]}, :project_id => 1 }

    # find updated issue
    issue = Issue.find(1)
    assert_kind_of Issue, issue

    # check redirection
    assert_redirected_to :controller => 'issues', :action => 'show', :id => issue
    follow_redirect!
    assert_equal issue, assigns(:issue)

    # check issue attributes
    assert_equal 'jsmith', issue.author.login
    assert_equal 1, issue.project.id
    assert_equal [2,3,4], issue.projects.collect(&:id)
  end

  # remove the unique other project
  def test_remove_unique_other_project
    log_user('jsmith', 'jsmith')
    get 'issues/1/edit'
    assert_response :success
    assert_template 'issues/edit'
    assert_select "p#projects_form", :count => 1

    put 'issues/1', {:issue => { :project_ids => [2]}, :project_id => 1 }

    # find updated issue
    issue = Issue.find(1)
    assert_kind_of Issue, issue

    # check redirection
    assert_redirected_to :controller => 'issues', :action => 'show', :id => issue
    follow_redirect!
    assert_equal issue, assigns(:issue)

    # check issue attributes
    assert_equal 'jsmith', issue.author.login
    assert_equal 1, issue.project.id
    assert_equal [2], issue.projects.collect(&:id)

    ### Remove other project
    put 'issues/1', {:issue => { :project_ids => [""]}, :project_id => 1 }

    # find updated issue
    issue = Issue.find(1)
    assert_kind_of Issue, issue

    # check redirection
    assert_redirected_to :controller => 'issues', :action => 'show', :id => issue
    follow_redirect!
    assert_equal issue, assigns(:issue)

    # check issue attributes
    assert_equal 'jsmith', issue.author.login
    assert_equal 1, issue.project.id
    assert_equal [], issue.projects.collect(&:id)
  end

  def test_show_issue_with_several_projects
    multiproject_issue = Issue.find(4) # project_id = 2
    multiproject_issue.projects = [multiproject_issue.project, Project.find(5)]
    multiproject_issue.save!

    log_user('jsmith', 'jsmith')
    get 'issues/4'
    assert_response :success
    assert_template 'issues/show'
    assert_not_nil assigns(:issue).projects
    assert assigns(:issue).projects.present?
    assert_select 'div#current_projects_list', :count => 1
  end

  def test_show_issue_with_no_other_projects
    monoproject_issue = Issue.find(4) # project_id = 2
    monoproject_issue.projects = [monoproject_issue.project]
    monoproject_issue.save!

    log_user('jsmith', 'jsmith')
    get 'issues/4'
    assert_response :success
    assert_template 'issues/show'
    assert assigns(:issue)
    assert_equal assigns(:issue).projects, [Project.find(2)]
    assert_select 'div#current_projects_list', :count => 0
  end

end
