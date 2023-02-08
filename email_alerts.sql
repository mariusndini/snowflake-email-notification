// EMAIL INTEGRATION
// https://docs.snowflake.com/en/user-guide/email-stored-procedures.html
create notification integration my_email_int
    type=email
    enabled=true
    allowed_recipients=('Your.Email@Company.com')
;


// PUBLIC PREVIEW
// Email stored proc
// https://docs.snowflake.com/en/sql-reference/email-stored-procedures.html
call system$send_email(
    'my_email_int',
    'Your.Email@Company.com',
    'Email Alert: THIS IS YOUR SUBJECT.',
    'Task A has successfully finished. THIS IS YOUR BODY'
);



// PRIVATE PREVIEW
// https://docs.snowflake.com/en/LIMITEDACCESS/alerts.html

create or replace alert myalert
  warehouse = YOUR_WAREHOUSE
  schedule = '60 minute'
  if( 
      exists(select 1)
  )then
    call system$send_email(
        'my_email_int',
        'marius.ndini@snowflake.com',
        'Email Alert: Task A has finished.',
        'Status:'|| ( select PARSE_JSON(system$pipe_status('DB.SCHEMA.PIPE')):executionState::STRING ) || '\n' ||
        'Pendind Count:'|| ( select PARSE_JSON(system$pipe_status('DB.SCHEMA.PIPE')):pendingFileCount::STRING ) || '\n' ||
        'Outstanding MSG:'|| ( select PARSE_JSON(system$pipe_status('DB.SCHEMA.PIPE')):numOutstandingMessagesOnChannel::STRING ) || '\n' ||
        'Last MSG:'|| ( select PARSE_JSON(system$pipe_status('DB.SCHEMA.PIPE')):lastReceivedMessageTimestamp::STRING )
    );
    )// END SEND EMAIL
;

// BEGIN THE ALERT
alter alert myalert resume;

// SUSPEND THE ALERT
alter alert myalert suspend;

// desc alert
describe alert myalert;


// ALERTS HISTORY
select *
from
  table(information_schema.alert_history(
    scheduled_time_range_start
      =>dateadd('hour',-1,current_timestamp())))
order by scheduled_time desc;












