import os
from odps import ODPS

def main():
    # 确保 ALIBABA_CLOUD_ACCESS_KEY_ID 环境变量设置为用户 Access Key ID，
    # ALIBABA_CLOUD_ACCESS_KEY_SECRET 环境变量设置为用户 Access Key Secret，
    o = ODPS(
        os.getenv('ALIBABA_CLOUD_ACCESS_KEY_ID'),
        os.getenv('ALIBABA_CLOUD_ACCESS_KEY_SECRET'),
        #os.environ['ALIBABA_CLOUD_ACCESS_KEY_ID'],
        #os.environ['ALIBABA_CLOUD_ACCESS_KEY_SECRET'],
        project='project', # 项目名
        endpoint='http://service.cn-hangzhou-xxx:80/api' # 官方接口
    )

    result = o.execute_sql('SELECT * FROM my_table LIMIT 3')
    with result.open_reader() as reader:
        for record in reader:
            print(record)

if __name__ == "__main__":
    main()
