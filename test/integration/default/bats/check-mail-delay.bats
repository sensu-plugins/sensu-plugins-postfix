#!/usr/bin/env bats

setup() {
  export CHECK_MAIL_DELAY="sudo -u sensu /opt/sensu/embedded/bin/check-mail-delay.rb"
}

teardown() {
  clear_queue
  unset_connect_timeout
  postfix reload
}

clear_queue() {
  postsuper -d ALL
}

set_connect_timeout() {
  echo "smtp_connect_timeout = $1" >> /etc/postfix/main.cf
  postfix reload
}

unset_connect_timeout() {
  sed -i '/^smtp_connect_timeout/d' /etc/postfix/main.cf
  postfix reload
}

populate_queue() {
  for n in `seq 1 $1`; do
    echo pants | mail user$n@example.com
  done
}

populate_hold_queue() {
  populate_queue $1
  postsuper -h ALL
}

populate_deferred_queue() {
  set_connect_timeout 1
  populate_queue $1
  sleep 4
  unset_connect_timeout
}

@test "Check default (all) queue, ok" {
  populate_hold_queue 2
  populate_queue 3
  run $CHECK_MAIL_DELAY -w 10 -c 20
  [ $status = 0 ]
  [ "$output" = "PostfixMailDelay OK: 0 messages in the postfix mail queue older than 3600 seconds" ]
}

@test "Check default (all) queue, warning" {
  populate_hold_queue 3
  populate_queue 2
  sleep 2
  run $CHECK_MAIL_DELAY -d 1 -w 4 -c 20
  [ $status = 1 ]
  [ "$output" = "PostfixMailDelay WARNING: 5 messages in the postfix mail queue older than 1 seconds" ]
}

@test "Check default (all) queue, critical" {
  populate_hold_queue 1
  populate_queue 4
  sleep 2
  run $CHECK_MAIL_DELAY -d 1 -w 4 -c 5
  [ $status = 2 ]
  [ "$output" = "PostfixMailDelay CRITICAL: 5 messages in the postfix mail queue older than 1 seconds" ]
}

@test "Check all queues, ok" {
  populate_hold_queue 3
  populate_queue 2
  run $CHECK_MAIL_DELAY -q all -w 10 -c 20
  [ $status = 0 ]
  [ "$output" = "PostfixMailDelay OK: 0 messages in the postfix mail queue older than 3600 seconds" ]
}

@test "Check all queues, warning" {
  populate_hold_queue 3
  populate_queue 2
  sleep 2
  run $CHECK_MAIL_DELAY -q all -d 1 -w 4 -c 20
  [ $status = 1 ]
  [ "$output" = "PostfixMailDelay WARNING: 5 messages in the postfix mail queue older than 1 seconds" ]
}

@test "Check all queues, critical" {
  populate_hold_queue 3
  populate_queue 2
  sleep 2
  run $CHECK_MAIL_DELAY -q all -d 1 -w 4 -c 5
  [ $status = 2 ]
  [ "$output" = "PostfixMailDelay CRITICAL: 5 messages in the postfix mail queue older than 1 seconds" ]
}

@test "Check active queue, ok" {
  populate_hold_queue 10
  populate_deferred_queue 1
  populate_queue 5
  run $CHECK_MAIL_DELAY -q active -w 10 -c 20
  [ $status = 0 ]
  [ "$output" = "PostfixMailDelay OK: 0 messages in the postfix active queue older than 3600 seconds" ]
}

@test "Check active queue, warning" {
  populate_hold_queue 10
  populate_queue 5
  sleep 2
  run $CHECK_MAIL_DELAY -q active -d 1 -w 4 -c 20
  [ $status = 1 ]
  [ "$output" = "PostfixMailDelay WARNING: 5 messages in the postfix active queue older than 1 seconds" ]
}

@test "Check active queue, critical" {
  populate_hold_queue 10
  populate_queue 5
  sleep 2
  run $CHECK_MAIL_DELAY -q active -d 1 -w 4 -c 5
  [ $status = 2 ]
  [ "$output" = "PostfixMailDelay CRITICAL: 5 messages in the postfix active queue older than 1 seconds" ]
}

# Not sure how to test the incoming queue more thoroughly
@test "Check incoming queue, ok" {
  populate_hold_queue 10
  populate_queue 5
  sleep 2
  run $CHECK_MAIL_DELAY -q incoming -w 1 -c 1
  [ $status = 0 ]
  [ "$output" = "PostfixMailDelay OK: 0 messages in the postfix incoming queue older than 3600 seconds" ]
}

@test "Check deferred queue, ok" {
  populate_hold_queue 10
  populate_deferred_queue 2
  populate_queue 1
  run $CHECK_MAIL_DELAY -q deferred -w 5 -c 10
  [ $status = 0 ]
  [ "$output" = "PostfixMailDelay OK: 0 messages in the postfix deferred queue older than 3600 seconds" ]
}

@test "Check deferred queue, warning" {
  populate_hold_queue 2
  populate_deferred_queue 2
  populate_queue 2
  sleep 2
  run $CHECK_MAIL_DELAY -q deferred -d 1 -w 2 -c 5
  [ $status = 1 ]
  [ "$output" = "PostfixMailDelay WARNING: 2 messages in the postfix deferred queue older than 1 seconds" ]
}

@test "Check deferred queue, critical" {
  populate_hold_queue 2
  populate_deferred_queue 3
  populate_queue 2
  sleep 2
  run $CHECK_MAIL_DELAY -q deferred -d 1 -w 2 -c 3
  [ $status = 2 ]
  [ "$output" = "PostfixMailDelay CRITICAL: 3 messages in the postfix deferred queue older than 1 seconds" ]
}

@test "Check hold queue, ok" {
  populate_hold_queue 5
  populate_queue 2
  run $CHECK_MAIL_DELAY -q hold -w 10 -c 20
  [ $status = 0 ]
  [ "$output" = "PostfixMailDelay OK: 0 messages in the postfix hold queue older than 3600 seconds" ]
}

@test "Check hold queue, warning" {
  populate_hold_queue 5
  populate_queue 2
  sleep 2
  run $CHECK_MAIL_DELAY -q hold -d 1 -w 4 -c 20
  [ $status = 1 ]
  [ "$output" = "PostfixMailDelay WARNING: 5 messages in the postfix hold queue older than 1 seconds" ]
}

@test "Check hold queue, critical" {
  populate_hold_queue 10
  populate_queue 2
  sleep 2
  run $CHECK_MAIL_DELAY -q hold -d 1 -w 5 -c 10
  [ $status = 2 ]
  [ "$output" = "PostfixMailDelay CRITICAL: 10 messages in the postfix hold queue older than 1 seconds" ]
}
