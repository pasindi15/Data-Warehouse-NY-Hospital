# Data Warehouse - NY Hospital

A comprehensive Data Warehousing and Business Intelligence (DWBI) solution for analyzing NY State Hospital inpatient discharge data from 2009. This project implements a complete ETL pipeline using SQL Server and SSIS to transform raw operational data into a structured data warehouse optimized for analytics.

## 📋 Project Overview

This project was developed as part of an IT Data Warehousing and Business Intelligence assignment (IT3021). It demonstrates best practices in:

- **Star Schema Design**: Normalized dimension tables with a fact table for efficient analytics
- **Slowly Changing Dimensions (SCD)**: Type 2 implementation for hospital dimension tracking
- **ETL Operations**: SQL Server Integration Services (SSIS) packages for automated data loading
- **Data Transformation**: Complex transformations from multiple data sources
- **Accumulating Facts**: Tracking multiple events in hospital admission workflow

## 📊 Architecture

### Database Design

The solution uses a **Star Schema** architecture with the following components:

#### Dimension Tables
- **DimDate**: Time period analysis (year, quarter, month) - SCD Type 0 (static)
- **DimHospital**: Hospital/facility information with SCD Type 2 (tracks changes over time)
  - Captures facility details, county, and health service area
  - Maintains effective dates for historical accuracy
- **DimPatient**: Patient demographics aggregated by characteristics
  - Age groups, gender, race, ethnicity
  - 3-digit zip code grouping
  - No individual patient ID (anonymized)

#### Fact Table
- **FactAdmission**: Accumulating fact table capturing hospital admission workflow
  - Admission date, discharge date, length of stay
  - Multiple status indicators for workflow progress
  - Links to all dimension tables via surrogate keys
  - Allows tracking of admission lifecycle events

### Data Sources

Raw data is sourced from:
1. **source1_admissions.csv** - Admission records
2. **source2_hospital_master.sql** - Hospital/facility reference data
3. **source3_reference_data.xlsx** - Additional reference data
4. **source4_txn_completions.csv** - Transaction completion status

## 🗂️ Project Structure

```
Data-Warehouse-NY-Hospital/
├── README.md                           # This file
├── Documentation/
│   └── DWBI Assignment 1 [IT23603004].pdf    # Full project documentation
├── Schema_Design/
│   └── Star scema diagram.png          # Visual schema diagram
├── Source_Files/
│   ├── source1_admissions.csv          # Admission data
│   ├── source2_hospital_master.sql     # Hospital master data
│   ├── source3_reference_data.xlsx     # Reference data
│   ├── source4_txn_completions.csv     # Completion status
│   ├── Task4_Create_DataWarehouse.sql  # Database creation script
│   └── Task4_Verify.sql                # Verification queries
├── SQL queries/
│   └── SQLQuery*.sql                   # Analysis and diagnostic queries
└── NYHospital_ETL/                     # SSIS Project
    ├── NYHospital_ETL.sln              # Visual Studio solution
    ├── NYHospital_ETL/
    │   ├── Load_Dimensions.dtsx        # Load dimension tables
    │   ├── Load_FactAdmission.dtsx      # Load fact table
    │   ├── Load_FactAdmission_SSIS.dtsx # Alternative SSIS package
    │   ├── Update_AccumulatingFact.dtsx # Update fact table status
    │   ├── NYHospitalDW.conmgr         # Connection manager
    │   └── Project.params              # Project parameters
    └── bin/Development/                # Compiled SSIS packages (.ispac)
```

## 🚀 Setup Instructions

### Prerequisites
- SQL Server (2016 or later)
- SQL Server Data Tools (SSDT)
- SQL Server Integration Services (SSIS)
- Visual Studio 2012 or later

### Step 1: Create the Database

Run the database creation script to set up the data warehouse:

```bash
sqlcmd -S <server_name> -d master -i "Source_Files\Task4_Create_DataWarehouse.sql"
```

This will create:
- `NYHospitalDW` database
- All dimension tables (DimDate, DimHospital, DimPatient)
- FactAdmission fact table
- Necessary indexes and constraints

### Step 2: Verify Database Structure

Run the verification script to confirm all tables were created correctly:

```bash
sqlcmd -S <server_name> -d NYHospitalDW -i "Source_Files\Task4_Verify.sql"
```

### Step 3: Configure SSIS Packages

1. Open `NYHospital_ETL\NYHospital_ETL.sln` in Visual Studio
2. Configure connection manager in `NYHospitalDW.conmgr`
   - Set SQL Server instance name
   - Update authentication credentials
3. Update project parameters in `Project.params`
   - Data source folder paths
   - Database connection details

### Step 4: Run ETL Packages

Execute SSIS packages in the following order:

1. **Load_Dimensions.dtsx**
   - Populates DimDate with all time periods
   - Loads DimHospital from hospital master source
   - Loads DimPatient demographics

2. **Load_FactAdmission.dtsx**
   - Loads admission records from source data
   - Transforms and validates data
   - Updates fact table with all admission workflows

3. **Update_AccumulatingFact.dtsx** (Optional)
   - Updates fact table with additional status indicators
   - Tracks workflow progression

## 📈 Key Features

### Star Schema Benefits
- ✅ Denormalized design for fast query performance
- ✅ Simplified analytical queries
- ✅ Clear dimension hierarchies

### Data Quality
- ✅ Surrogate key implementation for stability
- ✅ Natural key indexing for efficient lookups
- ✅ Referential integrity via foreign keys
- ✅ Validation during ETL loading

### Historical Tracking
- ✅ SCD Type 2 for hospital attributes (captures changes over time)
- ✅ Effective date tracking
- ✅ Current flag for easy filtering

### Accumulating Facts
- ✅ Tracks multiple events in patient journey
- ✅ Admission, treatment, and discharge milestones
- ✅ Status indicators for workflow progress

## 📝 Sample Queries

### Query 1: Admissions by Hospital and Quarter
```sql
SELECT 
    h.facility_name,
    d.year_quarter,
    COUNT(f.admission_key) AS admission_count
FROM FactAdmission f
INNER JOIN DimHospital h ON f.hospital_key = h.hospital_key
INNER JOIN DimDate d ON f.discharge_date_key = d.date_key
WHERE h.is_current = 1
GROUP BY h.facility_name, d.year_quarter
ORDER BY d.year_quarter, admission_count DESC;
```

### Query 2: Average Length of Stay by Age Group
```sql
SELECT 
    p.age_group,
    AVG(f.length_of_stay) AS avg_los,
    COUNT(f.admission_key) AS admission_count
FROM FactAdmission f
INNER JOIN DimPatient p ON f.patient_key = p.patient_key
GROUP BY p.age_group
ORDER BY avg_los DESC;
```

### Query 3: Hospital Admissions by County and Race
```sql
SELECT 
    h.hospital_county,
    p.race,
    COUNT(f.admission_key) AS admission_count
FROM FactAdmission f
INNER JOIN DimHospital h ON f.hospital_key = h.hospital_key
INNER JOIN DimPatient p ON f.patient_key = p.patient_key
WHERE h.is_current = 1
GROUP BY h.hospital_county, p.race
ORDER BY hospital_county, admission_count DESC;
```

## 📚 Data Dictionary

### DimDate Table
| Column | Type | Description |
|--------|------|-------------|
| date_key | INT | Surrogate key (YYYYMMDD format) |
| discharge_year | INT | Year of discharge (e.g., 2009) |
| quarter | INT | Quarter (1-4) |
| month | INT | Month (1-12) |
| month_name | VARCHAR(20) | Month name (e.g., 'January') |
| year_quarter | VARCHAR(10) | Formatted year-quarter (e.g., '2009-Q1') |
| year_month | VARCHAR(10) | Formatted year-month (e.g., '2009-01') |

### DimHospital Table (SCD Type 2)
| Column | Type | Description |
|--------|------|-------------|
| hospital_key | INT | Surrogate key (identity) |
| facility_id | INT | Natural key from source |
| facility_name | VARCHAR(100) | Hospital name |
| operating_cert_number | VARCHAR(20) | Operating certificate |
| hospital_county | VARCHAR(50) | County location |
| health_service_area | VARCHAR(50) | Health service area |
| effective_start_date | DATE | When this version became active |
| effective_end_date | DATE | When this version expired (NULL = current) |
| is_current | BIT | 1 = current, 0 = historical |

### DimPatient Table
| Column | Type | Description |
|--------|------|-------------|
| patient_key | INT | Surrogate key (identity) |
| age_group | VARCHAR(20) | Age grouping (0-17, 18-29, 30-49, 50-69, 70+) |
| gender | CHAR(1) | M=Male, F=Female, U=Unknown |
| race | VARCHAR(50) | Patient race category |
| ethnicity | VARCHAR(30) | Spanish/Hispanic origin |
| zip_code_3digit | VARCHAR(10) | 3-digit zip code grouping |

### FactAdmission Table
| Column | Type | Description |
|--------|------|-------------|
| admission_key | INT | Surrogate key (identity) |
| hospital_key | INT | FK to DimHospital |
| patient_key | INT | FK to DimPatient |
| admission_date_key | INT | FK to DimDate (admission) |
| discharge_date_key | INT | FK to DimDate (discharge) |
| length_of_stay | INT | Days between admission and discharge |
| [Additional Status Columns] | | Workflow progress indicators |

## 🔍 Analysis Use Cases

This data warehouse supports:

1. **Operational Analytics**
   - Hospital capacity planning
   - Average length of stay trends
   - Admission volume by facility

2. **Patient Outcome Analysis**
   - Discharge patterns by demographics
   - Admission trends by age and race
   - Geographic distribution analysis

3. **Performance Metrics**
   - Hospital comparison by region
   - Quarterly admission trends
   - Resource utilization rates

## 📋 ETL Package Details

### Load_Dimensions.dtsx
- **Purpose**: Populates all dimension tables
- **Source**: SQL scripts and CSV files
- **Targets**: DimDate, DimHospital, DimPatient
- **Key Logic**: SCD Type 2 handling for hospitals

### Load_FactAdmission.dtsx
- **Purpose**: Loads main admission facts
- **Source**: source1_admissions.csv
- **Target**: FactAdmission table
- **Transformations**: 
  - Key lookups (dimension keys)
  - Data validation
  - Length of stay calculation

### Update_AccumulatingFact.dtsx
- **Purpose**: Updates fact table status fields
- **Source**: source4_txn_completions.csv
- **Target**: FactAdmission (update)
- **Logic**: Accumulating fact status updates

## 🛠️ Troubleshooting

### Package Execution Issues
1. Verify SQL Server connection manager settings
2. Check source file paths in package parameters
3. Review SSIS execution logs for specific errors
4. Ensure database exists before package execution

### Data Validation
- Run `Task4_Verify.sql` to check table structure
- Query dimension tables for complete load
- Validate foreign key relationships
- Check row counts match expectations

## 📖 References

- **Dataset**: NY State Hospital Inpatient Discharge Data (2009)
- **Schema**: Star schema with SCD Type 2 dimensions
- **Tools**: SQL Server, SSIS, SSDT
- **Course**: IT3021 - Data Warehousing and Business Intelligence

## 📄 License

This project was created for academic purposes as part of IT3021 coursework.

## 👤 Author

Created for Data Warehouse design and ETL implementation assignment.

---

**Last Updated**: April 2026

For questions or issues with this data warehouse, refer to the SQL queries in the `SQL queries/` folder or the full documentation in `Documentation/`.
