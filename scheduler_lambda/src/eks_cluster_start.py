import boto3
import os

region = 'ap-northeast-2'
eksClient = boto3.client('eks', region_name=region)
autoscalingClient = boto3.client('autoscaling')


def lambda_handler(event, context):
    # Get AutoScalingGroupName
    # Get Key, Value from lambda environment
    key_auto_scheduler = os.environ['AUTO_SCHEDULE_KEY']
    value_auto_scheduler = os.environ['AUTO_SCHEDULE_VALUE']
    key_cluster = os.environ['KEY']
    value_cluster = os.environ['VALUE']

    response = eksClient.describe_cluster(name=value_cluster)
    arn = response['cluster']['arn']
    tag_list = eksClient.list_tags_for_resource(resourceArn=arn)
    arr_tags = tag_list['tags']

    print('[TagList] {0}'.format(arr_tags))

    check_auto_scheduler = False

    # Check Tags for AutoScheduler
    for tag in arr_tags:
        if tag == key_auto_scheduler and arr_tags[tag] == value_auto_scheduler:
            check_auto_scheduler = True

    if check_auto_scheduler:
        try:
            asg_name = get_asg_name_from_tags({key_cluster:value_cluster})
            print('asg_id : ' + asg_name)

            # Update AutoScalingGroup MinSize, DesiredCapacity
            response = autoscalingClient.update_auto_scaling_group(
                AutoScalingGroupName=asg_name,
                MinSize=2,
                DesiredCapacity=2
            )
            print('Start EKS Worker node')
        except:
            print(f'Occurred exception')


def get_asg_name_from_tags(tags):
    asg_name = None

    while True:
        paginator = autoscalingClient.get_paginator('describe_auto_scaling_groups')
        page_iterator = paginator.paginate(
            PaginationConfig={'PageSize': 100}
        )
        filter = 'AutoScalingGroups[]'

        for tag in tags:
            print('tag : ' + tag)
            print('tags[tag] : ' + tags[tag])
            filter = ('{} | [?contains(Tags[?Key==`{}`].Value, `{}`)]'.format(filter, tag, tags[tag]))
        filtered_asg = page_iterator.search(filter)
        asg = next(filtered_asg)
        asg_name = asg['AutoScalingGroupName']

        try:
            asg_x = next(filtered_asg)
            asg_x_name = asg['AutoScalingGroupName']
            raise AssertionError('multiple ASG\'s found for {} = {},{}'
                     .format(tags, asg_name, asg_x_name))
        except StopIteration:
            break
    return asg_name
