require 'spec_helper'

describe Ci::SendPipelineNotificationService, services: true do
  let(:pipeline) do
    create(:ci_pipeline, project: project, sha: project.commit('master').sha)
  end

  let(:project) { create(:project) }
  let(:user) { create(:user) }
  subject{ described_class.new(pipeline) }

  describe '#execute' do
    before do
      reset_delivered_emails!
    end

    shared_examples 'sending emails' do
      it 'sends an email to pipeline user' do
        perform_enqueued_jobs do
          subject.execute([user.email])
        end

        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to include(email_subject)
        expect(email.to).to eq([user.email])
      end
    end

    context 'with success pipeline' do
      let(:status) { 'success' }
      let(:email_subject) { 'Pipeline succeeded for' }

      it_behaves_like 'sending emails'
    end

    context 'with failed pipeline' do
      let(:status) { 'failed' }
      let(:email_subject) { 'Pipeline failed for' }

      it_behaves_like 'sending emails'
    end
  end
end
