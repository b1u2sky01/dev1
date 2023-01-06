import boto3
import os

region = 'ap-northeast-2'
client = boto3.client('rds', region_name=region)


def lambda_handler(event, context):
    turn_off_rds()


def turn_off_rds():
    key = os.environ['AUTO_SCHEDULE_KEY']
    value = os.environ['AUTO_SCHEDULE_VALUE']

    response = client.describe_db_clusters()

    for instance in response['DBClusters']:
        cluster_arn = instance['DBClusterArn']
        tag_list = client.list_tags_for_resource(ResourceName=cluster_arn)
        print('[TagList] {0}'.format(tag_list['TagList']))

        if 0 == len(tag_list['TagList']):
            print('DB Cluster {0} is not part of scheduler'.format(instance['DBClusterIdentifier']))
        else:
            # Check Tags for AutoScheduler
            check_auto_scheduler = False

            for tag in tag_list['TagList']:
                if tag['Key'] == key and tag['Value'] == value:
                    if instance['Status'] == 'available':
                        check_auto_scheduler = True

            if check_auto_scheduler:
                client.stop_db_cluster(DBClusterIdentifier=instance['DBClusterIdentifier'])
                print('Stopping DB cluster {0}'.format(instance['DBClusterIdentifier']))
            else:
                print('DB Instance {0} is not part of auto scheduler'.format(instance['DBClusterIdentifier']))
