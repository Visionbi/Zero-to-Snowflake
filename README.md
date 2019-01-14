# Zero-to-Snowflake
The scripts you need to get started with Snowflake, the enterprise data warehouse built for the cloud. 

The purpose of this repository is to help companies when they start using Snowflake. It contains help for some of the most common tasks when developing your Data Lake or Analytics Platform using Snowflake.

The exercises/tasks can be done using SNOWFLAKE_SAMPLE_DATA database (you’ll see this sample database on your snowflake account). This means that there are no prerequisites, besides an S3 bucket with write permissions (Access_Key & Secret_Key)

This repository of tips and tools is managed by [Vision.bi](https://vision.bi), Snowflake’s consulting and technology partner. For high-level consulting queries, you can contact us at [snowflake@vision.bi](mailto:snowflake@vision.bi)

<b>*NOTE:</b> The demo will load data from S3 into Snowflake using scripts, which can be scheduled and executed with Python, Airflow, or others. We highly recommend using
 [Rivery - Data Pipeline to Snowflake](https://rivery.io/rivery-snowflake-empowering-businesses-to-build-a-fully-managed-data-pipeline/) in order to Schedule SQL tasks, run insert scripts or load data from external sources (i.e. Facebook Social, Facebook Ads or Google Adwords). 


## Step 1 - Prepare Data For The Demo
Fisrt we will prepare some data. Snowflake includes a Sample database (Using their snowshare), we will use it for the demo, you'll need to prepare only a bucket with secret & access keys.

see documentation [here](/A-Tutorial/Step-1-Prepare-Data.MD)

## Step 2 - Load Data
Use Copy from different sources as Parquet, CSV & Json.

see documentation [here](/A-Tutorial/Step-2-Loading-Data.MD)


## Step 3 - Data Extract & Load
Resize Warehouse, Extract data from Semi Structure, Merge and more...
see documentation [here](/A-Tutorial/Step-3-data-extract-and-load.MD)

## And More...
Explore tye repository for more examples, please fill free to ask for samples in the [issues section](https://github.com/Visionbi/Zero-to-Snowflake/issues)

###<i>Enjoy Snowflaking...</i>

