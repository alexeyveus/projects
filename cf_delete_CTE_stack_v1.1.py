import boto3

from datetime import datetime, timedelta
from botocore.exceptions import ClientError,NoRegionError


NOT_IN_OPERATE_STACKS = ['ROLLBACK_COMPLETE', 'UPDATE_ROLLBACK_COMPLETE', 'CREATE_COMPLETE',
                         'ROLLBACK_FAILED', 'CREATE_FAILED', 'UPDATE_COMPLETE', 'UPDATE_ROLLBACK_FAILED']

FULL_STACKS_LIST = ['CREATE_IN_PROGRESS', 'CREATE_FAILED', 'CREATE_COMPLETE', 'ROLLBACK_IN_PROGRESS',
                    'ROLLBACK_FAILED', 'ROLLBACK_COMPLETE', 'UPDATE_IN_PROGRESS',
                    'UPDATE_COMPLETE_CLEANUP_IN_PROGRESS', 'UPDATE_COMPLETE', 'UPDATE_ROLLBACK_IN_PROGRESS',
                    'UPDATE_ROLLBACK_FAILED', 'UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS',
                    'UPDATE_ROLLBACK_COMPLETE', 'REVIEW_IN_PROGRESS', 'DELETE_IN_PROGRESS', 'DELETE_FAILED']


def print_logo():
    print("***********************************************")
    print("*                                             *")
    print("* Scipt for deleting CloudFormation Stacks. v1*")
    print("*                                             *")
    print("* Designed by OpsWorks Inc                    *")
    print("*                                             *")
    print("***********************************************\n\n\n")


def call_menu():
    try:
        cf = boto3.client('cloudformation')
    except NoRegionError:
        print("\nYou need to specify an AWS configuration before start script!\nScript use local default AWS config")
        raise SystemExit(1)

    print("Main menu. Please choose what to do:\n")
    print("1 - List all stacks in tabular form")
    print("2 - List of all stacks containing 'CTE' in the name")
    print("3 - Delete custom stack by the StackName")
    print("4 - Delete all stacks containing 'CTE' in a StackName older than 14 days")
    print("5 - Print log file\n")
    print("0 - exit")
    choice = input("\n\nPlease choose menu digit: ")
    try:
        choice = int(choice)
    except ValueError:
        print("Incorrect input. Try again")
        print("\n\nPress 'enter' to continue...")
        input()
        call_menu()

    if int(choice) == 0:
        print("Bye")
        exit(0)

    elif int(choice) == 1:
        stacks = cf.list_stacks(StackStatusFilter=FULL_STACKS_LIST)['StackSummaries']
        print_list_stacks(stacks, False)
        print("\n\nPress 'enter' to return to menu...")
        input()
        call_menu()

    elif int(choice) == 2:
        stacks = cf.list_stacks(StackStatusFilter=NOT_IN_OPERATE_STACKS)['StackSummaries']
        print_list_stacks(stacks, True)
        print("\n\nPress 'enter' to return to menu...")
        input()
        call_menu()

    elif int(choice) == 3:
        stackName = input("Input StackName you want to delete: ")
        stacks = cf.list_stacks(StackStatusFilter=NOT_IN_OPERATE_STACKS)['StackSummaries']
        if is_exist_stack(stacks, stackName):
            print("\nAre you sure you want to delete the '", stackName,
                  "' stack ? \nWrite 'yes' if so. Any other words - Exit to menu.")
            res = input(": ")
            if res == 'yes':
                delete_custom_stack(stackName, 0)
            else:
                call_menu()
        else:
            print("Stack with name '", stackName, "' does not exist. Try again")
            print("\n\nPress 'enter' to continue...")
            input()
            call_menu()

    elif int(choice) == 4:
        stacks = cf.list_stacks(StackStatusFilter=NOT_IN_OPERATE_STACKS)['StackSummaries']
        print("\nAre you sure you want to delete all stacks content 'CTE' at StackName older than 14 days ?\n")
        print_list_stacks(stacks, True)
        print("\nWrite 'yes' if so. Any other inputs - Exit to menu.")
        res = input(": ")
        if res == 'yes':
            for stack in stacks:
                if "CTE" in stack['StackName']:
                    delete_custom_stack(stack['StackName'], 14)
            print("\n\nPress 'enter' to continue...")
            input()
            call_menu()
        else:
            call_menu()
        print("\n\nPress 'enter' to continue...")
        input()
        call_menu()

    elif int(choice) == 5:
        print_log_file("stacks_logs.txt")
        print("\n\nPress 'enter' to continue...")
        input()
        call_menu()

    else:
        print("Incorrect input. Try again")
        print("\n\nPress 'enter' to continue...")
        input()
        call_menu()


def add_log_record_to_file(logrecord):
    file_name = "stacks_logs.txt"
    logfile = open(file_name, mode='a')
    logfile.write(str(datetime.now()) + " | " + "deleted stack: " + logrecord + "\n")
    logfile.close()
    print("Record has been added to the log file about removing the stack. Log file store at local folder.\n")


def print_log_file(file_name):
    try:
        logfile = open(file_name)
        print(logfile.read())
        logfile.close()
    except FileNotFoundError:
        print("Log file not found")
    except PermissionError:
        print("You don not have the permissions to read log file")
    except:
        print("An error undefined has occurred")


def is_exist_stack(st, stackname):
    for stack in st:
        if stack['StackName'] == stackname:
            return True
    return False


def delete_custom_stack(stackName, age):
    cf_resource = boto3.resource('cloudformation')
    delta = timedelta(days=age)
    stacks = cf_resource.Stack(stackName)
    created_at = stacks.creation_time.replace(tzinfo=None)
    cur_time = datetime.now()
    target_date = cur_time - delta
    if created_at < target_date:
        print("Trying to delete stack '", stackName, "' ...")
        deleting_stack(stackName)
        add_log_record_to_file(stackName)
    else:
        print("\nStack '", stackName, "' younger than 14 days. Do not need to be deleted.")


def deleting_stack(stackname):
    cf = boto3.client('cloudformation')
    try:
        cf.delete_stack(StackName=stackname)
    except ClientError:
        return print("Cannot delete stack '", stackname, ". Probably stack already deleted or is in the process of executing.")
    return print("Stack '", stackname, "' successfully deleted.")


def print_header(stnamelen, creatlen, statuslen, length):
    x = round(((stnamelen / 2) - 6))
    y = round(((creatlen / 2) - 6))
    z = round(((statuslen / 2) - 6))

    print("-" * length)
    print(" " * x, "StackName", " " * x, "|", " " * y, "CreationTime", " " * (y-2), "|", " " * z, "StackStatus", " " * z)
    print("-" * length)


def print_list_stacks(st, is_cte):
    lengthSumm = 50
    lengthStackName = 35
    lengthCreatTime = 37
    lengthStatus = 35
    for stack in st:

        if lengthStackName < len(stack['StackName']):
            lengthStackName = len(stack['StackName'])
        if lengthCreatTime < len(str(stack['CreationTime'])):
            lengthCreatTime = len(str(stack['CreationTime']))
        if lengthStatus < len(stack['StackStatus']):
            lengthStatus = len(stack['StackStatus'])

        length = lengthStackName + lengthCreatTime + lengthStatus + 3
        if lengthSumm < length:
            lengthSumm = length

    print_header(lengthStackName, lengthCreatTime, lengthStatus, lengthSumm)
    if is_cte:
        for stack in st:
            if "CTE" in stack['StackName']:
                s = '{: ^' + str(lengthStackName) + '}| {: ^' + str(lengthCreatTime) + '}|{: ^' + str(lengthStatus) + '}'
                print(s.format(stack['StackName'], str(stack['CreationTime']), stack['StackStatus']))
    else:
        for stack in st:
            s = '{: ^' + str(lengthStackName) + '}| {: ^' + str(lengthCreatTime) + '}|{: ^' + str(lengthStatus) + '}'
            print(s.format(stack['StackName'], str(stack['CreationTime']), stack['StackStatus']))


def main():
    print_logo()
    call_menu()


if __name__ == "__main__":
    main()