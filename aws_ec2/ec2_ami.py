import boto3
import socket
from datetime import datetime, timedelta


class Task:

    def __init__(self):
        self.ec2 = boto3.resource('ec2')
        self.today = datetime.now()

        self.one_weeks = timedelta(days=7)
        self.target_date = self.today - self.one_weeks

    @staticmethod
    def ping_port():
        my_domains = ['eeam.pp.ua', 'eeam2.pp.ua', 'eeam3.pp.ua']
        ports = [22, 80]

        for d in my_domains:
            print('Ping Domain...', d)
            for port in ports:
                s = socket.socket()
                s.settimeout(1)
                try:
                    s.connect((d, port))
                except socket.error:
                    print('Port ', port, 'is not response')
                    pass
                else:
                    s.close
                    print('Port:', str(port) + ' is active')
            print('------------------------------------------------')

    def create_ami(self, instance):
        description = "not found"
        if instance:
            stopped_instance_id = instance.id
            if stopped_instance_id:
                new_ami = instance.create_image(
                    Name="AlekseyS_AMI_" + str(self.today.strftime('%m-%d-%Y-%H-%M-%S')),
                    Description=self.get_instance_name(instance) + str(self.today)
                )
                description = new_ami.description
        return description

    def get_instance(self, state='stopped'):
        stopped_ec2 = None
        for instance in self.ec2.instances.all():
            if instance.key_name == 'KeyPairEE':
                if instance.state["Name"] == state:
                    stopped_ec2 = instance
                    break
        return stopped_ec2

    def get_instance_name(self, instance):
        instancename = ''
        if instance:
            for tags in instance.tags:
                if tags["Key"] == 'Name':
                    instancename = tags["Value"]
        return instancename

    def kill_instance(self, instance):
        if instance:
            instance.terminate()
            return "terminated"
        else:
            return "error: invalid instance"

    @staticmethod
    def print_instance_details_table(instance):
        if instance:
            print('+{: ^20}+{: ^15}+{: ^18}+{: ^55}+{: ^17}+'.format(instance.id,
                                                                     instance.state['Name'],
                                                                     str(instance.public_ip_address),
                                                                     instance.public_dns_name,
                                                                     instance.image_id))

    def print_instances_table(self, key_name=""):
        print('+{:-^20}+{:-^15}+{:-^18}+{:-^55}+{:-^17}+'.format('-', '-', '-', '-', '-'))
        print('|{: ^20}|{: ^15}|{: ^18}|{: ^55}|{: ^17}|'.format('ID', 'STATE', ' IP', 'DNS', 'IMAGE ID'))
        print('+{:-^20}+{:-^15}+{:-^18}+{:-^55}+{:-^17}+'.format('-', '-', '-', '-', '-'))
        instances = self.ec2.instances.all()
        for instance in instances:
            if key_name == "" or instance.key_name == key_name:
                self.print_instance_details_table(instance)
        print('+{:-^20}+{:-^15}+{:-^18}+{:-^55}+{:-^17}+'.format('-', '-', '-', '-', '-'))

    def kill_old_ami(self, days):
        delta = timedelta(days)
        target_date = self.today - delta

        all_images = self.ec2.images.filter(Owners=['717986625066'])

        for image in all_images:
            created_at = datetime.strptime(
                image.creation_date,
                "%Y-%m-%dT%H:%M:%S.000Z",
            )
            if image.description[:7] == 'AlekseS' or image.description[:4] == 'test':
                if created_at < target_date:
                    print('- deregistate AMI ', image.name, ' created ', created_at, ' (', image.description, ')',
                          end="? (y/n)")
                    if input() == 'y':
                        print('deleted')
                        image.deregister()
                    else:
                        print('canceled')


def main():
    print("Create task...")
    task = Task()

    # Determine the instance state using DNS name of customer domains
    print("Run task: ping HTTP and SSH ports... `n")
    task.ping_port()

    # Getting stopped instances
    instance = task.get_instance('stopped')
    print("Run task: find stopped instance ... ", "OK" if instance else "not found")
    if instance:

        # Creating AMI of stopped instance
        print("Run task: create_ami ... ", task.create_ami(instance))

        # Terminate stopped instance
        print("Run task: kill_instance ... ", task.kill_instance(instance))

    # Printing detailed table of all instances
    print("Run task: Print all instances: for 'KeyPairEE'")
    task.print_instances_table("KeyPairEE")

    # Terminating all AMI`s older 7 days
    task.kill_old_ami(7)


if __name__ == "__main__":
    main()
