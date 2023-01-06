import boto3
import os

region = 'ap-northeast-2'
ec2 = boto3.resource('ec2', region_name=region)


def lambda_handler(event, context):
    key = os.environ['AUTO_SCHEDULE_KEY']
    value = os.environ['AUTO_SCHEDULE_VALUE']

    # find all ec2 instances
    instances = ec2.instances.filter(
        Filters=[{'Name': 'instance-state-name', 'Values': ['running']},
                 {'Name': 'tag:{0}'.format(key), 'Values': ['{0}'.format(value)]}]
    )

    # stop all instances
    for instance in instances:
        try:
            instance.stop()
            print(f'{instance} stopped')
        except:
            print(f'Occurred exception for {instance}')
