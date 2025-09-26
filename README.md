# Lyra Case API Assignment: External Case Creation

**A comprehensive REST API built for the Lyra Sr. Developer take-home assignment, designed to efficiently create support cases in Salesforce from external systems using Connected App / Oauth for credentials.**

***

## What It Does

This project provides a reliable **REST API endpoint** and **POST Request** route for creating new Case records. Optimized for integration with **external web and mobile applications** using secure OAuth 2.0.

* **Case Creation:** Accepts a JSON payload structured per the take home assignment specs -- maps customer and support request data directly to a new Salesforce Case.
* **Input Validation:** Strictly enforces that the `origin` field must be either `"web"` or `"mobile"`.
* **Logging:** All API Events (success or failure) are logged to a custom object (`API_Log__c`) for easier auditing and debugging.
* **Security:** Utilizes the **OAuth 2.0 Client Credentials Flow** for application-level authentication.

***

## Setup Instructions

### 1. Deployment

Get the code onto your Salesforce org:

1.  **Clone the Repository:**
    ```bash
    git clone [https://github.com/anthonykellyjr/Lyra_Case_API_Assignment.git](https://github.com/anthonykellyjr/Lyra_Case_API_Assignment.git)
    cd Lyra_Case_API_Assignment
    ```
2.  **Deploy Metadata:**
    ```bash
    sf project deploy start --source-dir force-app
    ```
3.  **Assign Permissions:** Ensure your Admin or Integration user has access to the API.
    ```bash
    sf org assign permset --name Connected_App_Admin
    ```

### 2. Configure the Connected App

The metadata for the Connected App is included in the deployment, but it requires a quick setup step in the UI:

1.  Navigate to **Setup** > **Apps** > **App Manager**.
2.  Locate the app named **"Case API Integration App"**.
3.  Click the dropdown arrow > **Manage** > **Edit Policies**.
4.  Under the **OAuth 2.0 Client Credentials Flow** section, set the **Run As** user to your designated **Integration User**.
5.  **Save** your changes.

### 3. Test User Credentials

Use these credentials to facilitate the OAuth flow during testing:

* **Username:** `lyra.tester@lyra.dev`
* **Password:** `LyraTesterDev1!`
* **Profile:** System Administrator
* *Note: This user must have the **Connected\_App\_Admin** permission set assigned.*

***

## API Details

| Detail | Value |
| :--- | :--- |
| **Endpoint** | `/services/apexrest/create-case/` |
| **HTTP Method** | `POST` |
| **Authentication** | OAuth 2.0 Client Credentials Flow |
| **Controller** | `CaseCreationApiController` |

### Request Body (JSON)

This is the payload structure for sending a new case request.

```json
{
  "subject": "Request for billing / payment method update",
  "description": "I would like to use a different card for billing co-pay after sessions.",
  "status": "New",
  "origin": "web", 
  "name": "Stevie Nicks",
  "phone": "555-4499",
  "email": "stevie@fleetwoodmac.com"
}