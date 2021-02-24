require 'rails_helper'

describe EadIndexer::PromMetrics do

  let(:app_name) { 'specialcollections' }
  let(:cronjob) { 'git-trigger' }
  let(:pushgateway_url) { 'http://pushgateway:9091' }
  let(:metrics_prefix) { 'nyu_web' }
  let(:prom_metrics) { EadIndexer::PromMetrics.new(app_name, cronjob) }
  let(:prom_metrics_with_pushgateway_url) { EadIndexer::PromMetrics.new(app_name, cronjob, pushgateway_url) }
  let(:prom_metrics_with_all_params) { EadIndexer::PromMetrics.new(app_name, cronjob, pushgateway_url, metrics_prefix) }

  before do
    allow_any_instance_of(EadIndexer::PromMetrics).to receive(:puts).and_return nil
  end

  describe '#app_name' do
    subject { prom_metrics.app_name }
    it { is_expected.to eql 'specialcollections' }
  end

  describe '#cronjob' do
    subject { prom_metrics.cronjob }
    it { is_expected.to eql 'git-trigger' }
  end

  describe '#pushgateway_url' do
    before { allow(ENV).to receive(:[]).with('PROM_PUSHGATEWAY_URL').and_return("http://localhost:9091") }
    let(:prom_metrics_instance) { prom_metrics }
    subject { prom_metrics_instance.pushgateway_url }
    context 'when pushgateway_url uses the default from env var' do
      it { is_expected.to eql 'http://localhost:9091' }
    end
    context 'when a custom push gateway url is sent as a param' do
      let(:prom_metrics_instance) { prom_metrics_with_pushgateway_url }
      it { is_expected.to eql 'http://pushgateway:9091' }
    end
  end

  describe '#metrics_prefix' do
    let(:prom_metrics_instance) { prom_metrics }
    subject { prom_metrics_instance.metrics_prefix }
    context 'when metrics_prefix uses the default' do
      it { is_expected.to eql 'nyulibraries_web' }
    end
    context 'when a custom metrics prefix is sent as a param' do
      let(:prom_metrics_instance) { prom_metrics_with_all_params }
      it { is_expected.to eql 'nyu_web' }
    end
  end

  describe '#push_metrics!' do
    # Skipping because I don't want to test Prometheus::Client::Push
    pending
  end

  describe '#register_metrics!' do
    subject { prom_metrics.register_metrics! }
    it { is_expected.to be_instance_of Prometheus::Client::Counter }
  end

  describe '#success_counter' do
    subject { prom_metrics.success_counter }
    it { is_expected.to be_instance_of Prometheus::Client::Counter }
  end

  describe '#failure_counter' do
    subject { prom_metrics.failure_counter }
    it { is_expected.to be_instance_of Prometheus::Client::Counter }
  end

end