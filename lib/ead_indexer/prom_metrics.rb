require 'prometheus/client'
require 'prometheus/client/push'

##
# PromMetrics
#
# This class has helper methods to setup a Prometheus registry for the indexer to send
# metrics 
class EadIndexer::PromMetrics

  attr_accessor :app_name, :cronjob, :pushgateway_url, :metrics_prefix

  def initialize(app_name, cronjob, pushgateway_url=ENV['PROM_PUSHGATEWAY_URL'], metrics_prefix='nyulibraries_web')
    @app_name = app_name
    @cronjob = cronjob
    @pushgateway_url = pushgateway_url
    @metrics_prefix = metrics_prefix
  end

  def push_metrics!
    Prometheus::Client::Push.new(app_name, 'index', pushgateway_url).add(registry)
  end

  def register_metrics!
    registry.register(success_counter)
    registry.register(failure_counter)
  end

  def default_labels
    { app: app_name, cronjob: cronjob }
  end

  def success_counter
    @success_counter ||= Prometheus::Client::Counter.new("#{metrics_prefix}_cron_success_total".to_sym, docstring: 'docstring', labels: [:action, :app, :cronjob])
  end

  def failure_counter
    @failure_counter ||= Prometheus::Client::Counter.new("#{metrics_prefix}_cron_failure_total".to_sym, docstring: 'docstring', labels: [:action, :ead, :app, :cronjob])
  end

 private

  def registry
    @registry ||= Prometheus::Client.registry
  end

end