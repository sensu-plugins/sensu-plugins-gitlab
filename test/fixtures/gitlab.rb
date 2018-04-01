def gitlab_health_good_response
  <<-JSON
    {
      "db_check": {
        "status": "ok"
      },
      "redis_check": {
        "status": "ok"
      },
      "cache_check": {
        "status": "ok"
      },
      "queues_check": {
        "status": "ok"
      },
      "shared_state_check": {
        "status": "ok"
      },
      "fs_shards_check": {
        "status": "ok"
      },
      "gitaly_check": {
        "status": "ok"
      }
    }
  JSON
end

def gitlab_health_bad_response
  <<-JSON
    {
      "db_check": {
        "status": "error"
      },
      "redis_check": {
        "status": "ok"
      },
      "cache_check": {
        "status": "ok"
      },
      "queues_check": {
        "status": "ok"
      },
      "shared_state_check": {
        "status": "ok"
      },
      "fs_shards_check": {
        "status": "ok"
      },
      "gitaly_check": {
        "status": "ok"
      }
    }
  JSON
end
