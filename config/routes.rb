# Copyright (c) 2011 Rice University.  All rights reserved.

Quadbase::Application.routes.draw do

  def commentable
    resources :comments, :only => [:index, :new, :create] do
      collection do
        get 'subscribe', :to => 'comment_thread_subscriptions#create',
                         :as => 'subscribe'
        get 'unsubscribe', :to => 'comment_thread_subscriptions#destroy',
                           :as => 'unsubscribe'
      end
    end
  end

  def flaggable
  end

  def sortable
    collection do
      post 'sort'
    end
  end

  def votable
    resources :votes, :only => [] do
      collection do
        post 'up'
        post 'down'
      end
    end
  end

  # TODO check that we're using put and post correctly.  
  # From: http://stackoverflow.com/questions/630453/put-vs-post-in-rest ...
  # "PUT is idempotent, so if you PUT an object twice, it has no effect. 
  # This is a nice property, so I would use PUT when possible."

  resources :website_configurations, :only => [:index] do
    collection do
      get 'edit'
      put 'update'
    end
  end

  resources :announcements, :except => [:edit, :update]

  get "admin", :to => 'admin#index', :as => "admin"

  resources :licenses do
    collection do
      put 'make_default'
    end
  end

  # For users, we mix devise with our own users controller.  We have overriden
  # some devise controller methods, so point that out here.
  devise_for :users, :controllers => {:registrations => "registrations"}

  post 'users/search'
  get 'users/help', :to => 'users#help', :as => 'account_help'

  resources :users, :only => [:index, :show, :edit, :update] do
    post 'become'
  end

  resources :deputizations, :only => [:create, :destroy, :new] do
    collection do
      post 'search'
    end
  end

  get "inbox", :to => 'inbox#index', :as => "inbox"

  get 'help', :to => 'help#index', :as => 'help'
  get 'help/faq', :to => 'help#faq', :as => 'faq'
  get 'help/contact', :to => 'help#contact', :as => 'contact'
  get 'help/beta', :to => 'help#beta', :as => 'beta'
  get 'about', :to => 'help#about', :as => 'about'
  get 'sitelicense', :to => 'home#sitelicense', :as => 'sitelicense'
  get 'help/authoring', :to => 'help#authoring', :as => 'authoring'
  get 'help/legal', :to => 'help#legal_faq', :as => 'legal'
  get 'help/images', :to => 'help#image_help', :as => 'images'
  get 'help/dialog', :to => 'help#dialog', :as => 'dialog'
  get 'help/comments', :to => 'help#comments', :as => 'comments'
  get 'help/messages', :to => 'help#message_help', :as => "messages"
  get 'help/roles', :to => 'help#roles_help', :as => 'roles'
  get 'help/topic/:topic_name', :to => 'help#topic', :as => 'topic_help'
  
  resources :projects do
    resources :project_members, :only => :create

    commentable

  end
  
  resources :project_members, :only => :destroy do
    put 'make_default'
  end

  resources :project_questions, :only => [] do
    collection do
      put 'update'
      put 'copy'
      put 'move'
      put 'preview_publish', :to => 'project_questions#preview_publish'
      put 'attribution'
      delete 'destroy'
    end
  end

  resources :questions do
    put 'preview'
    get 'history'

    resources :question_collaborators, :only => [:index, :create, :destroy] do
      sortable
    end

    resources :solutions, :only => [:index, :new]

    get 'license/edit', :to => "questions#edit_license", :as => 'edit_license'
    put 'license', :to => "questions#update_license", :as => 'license'

    collection do    
      put 'publish', :to => 'questions#publish'
      get 'publish', :to => 'questions#preview_publish'
      get 'get_started'
    end

    get 'source'
    put 'new_version'
    get 'derivation_dialog'
    put 'new_derivation'

    put 'edit_now'
    put 'edit_later'
    
    get 'part/:part_id', :to => "questions#show_part", :as => 'show_part'

    commentable
  end
  post 'questions/search'
  post 'questions/simple', :to => 'questions#create_simple', :as => 'create_simple_question'
  post 'questions/multipart', :to => 'questions#create_multipart', :as => 'create_multipart_question'

  resources :multipart_questions, :only => [] do
    put 'add_blank_part'
    post 'add_existing_parts'
  end

  resources :question_parts, :only => [:destroy] do
    sortable
  end
  
  resources :attachable_assets, :only => [:create, :destroy] do
    get 'download'
    get 'finish_create'
  end


  # Question subclasses need routes for create; however, they only need a 
  # controller that inherits from QuestionsController and that overrides
  # the create method (see QuestionsController.rb).  Any other question 
  # subclass route should be handled by the QuestionsController
  #
  # Note: the SimpleQuestions controller has been taken out b/c now everything
  # can be handled by the Questions controller.  Leaving these here for a while
  # now until we're sure everything works.
  #   resources :simple_questions, :only => [:create]
  #   resources :simple_questions, :controller => 'questions'

  resources :question_role_requests, :only => [:create, :destroy] do
    put 'accept'
    put 'reject'
    put 'approve'
    put 'veto'
  end
  
  resources :question_dependency_pairs, :only => [:create, :destroy]

  resources :solutions, :except => [:index, :new, :create] do
    commentable
    votable
  end

  resources :comments, :only => [:show, :edit, :update, :destroy] do
    votable
  end

  resources :messages, :only => [:new, :show] do
    post 'add_recipient'
    commentable
  end
  
  get 'subscriptions', :to => 'comment_thread_subscriptions#index', :as => 'subscriptions'

  match '/', :to => 'home#index', :as => ''
  root :to => 'home#index'
end