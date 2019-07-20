import boto3, os

from twindb_cloudflare.twindb_cloudflare import CloudFlare, CloudFlareException
from datetime import datetime, timedelta
from botocore.exceptions import ClientError, NoRegionError

NOT_IN_OPERATE_STACKS = ['ROLLBACK_COMPLETE', 'UPDATE_ROLLBACK_COMPLETE', 'CREATE_COMPLETE',
                         'ROLLBACK_FAILED', 'CREATE_FAILED', 'UPDATE_COMPLETE', 'UPDATE_ROLLBACK_FAILED']


def call_clean():

    passTag = "skip"

    try:
        cf = boto3.client('cloudformation')
    except NoRegionError:
        raise SystemExit(1)

    stacks = cf.describe_stacks().get('Stacks', [])
    for stack in stacks:
        trigger = True
        if "CTE" in stack['StackName']:
            if not stack['Tags']:
                delete_custom_stack(stack['StackName'], 14)
            else:
                for tag in stack['Tags']:
                    tagValue = tag['Value']
                    if tagValue.lower() == passTag:
                        trigger = False
                    tagValue = ""

            if trigger and stack['Tags']:
                delete_custom_stack(stack['StackName'], 14)


def delete_dns_record(stack_name):

    zone_name = "musclefood.com"
    dns_record_name = stack_name[6:-4] + "." + zone_name
    CLOUDFLARE_EMAIL = "**********"
    CLOUDFLARE_AUTH_KEY = "*************"

    cloudflare = CloudFlare(CLOUDFLARE_EMAIL, CLOUDFLARE_AUTH_KEY)

    try:
        cloudflare.delete_dns_record(dns_record_name, zone_name)
    except CloudFlareException as err:
        print(err)
        exit(-1)


def add_log_record_to_file(logrecord):
    s3 = boto3.resource('s3')
    file_name = "stacks_logs.txt"
    try:
        s3.meta.client.download_file('cloudformation-stack-logs', 'stacks_logs.txt', 'stacks_logs.txt')
    except ClientError:
        pass
    logfile = open(file_name, mode='a')
    logfile.write(str(datetime.now()) + " | " + "deleted stack: " + logrecord + "\n")
    logfile.close()
    s3.meta.client.upload_file('stacks_logs.txt', 'cloudformation-stack-logs', 'stacks_logs.txt')
    os.remove(file_name)


def delete_custom_stack(stackName, age):
    cf_resource = boto3.resource('cloudformation')
    delta = timedelta(days=age)
    stacks = cf_resource.Stack(stackName)
    created_at = stacks.creation_time.replace(tzinfo=None)
    cur_time = datetime.now()
    target_date = cur_time - delta
    if created_at < target_date:
        deleting_stack(stackName)
        delete_dns_record(stackName)
        add_log_record_to_file(stackName)


def deleting_stack(stackname):
    cf = boto3.client('cloudformation')
    try:
        cf.delete_stack(StackName=stackname)
    except:
        pass


def main():
    call_clean()


if __name__ == "__main__":
    main()
