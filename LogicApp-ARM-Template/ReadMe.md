Welcome to the repository for my Logic App ARM template! This repository contains the exported Logic App template along with placeholders for sensitive information to ensure security and flexibility.

Overview

This repository is intended for:

Sharing my Logic App template for offboarding automation.

Allowing easy reuse and customization of the template in different environments.

Demonstrating best practices for parameterized deployments using ARM templates.

The template uses placeholders for sensitive information, which must be replaced with actual values before deployment.

Placeholders in the Template

The following placeholders are used in the template:

<SubscriptionID>

Your Azure subscription ID.

<ResourceGroupName>

The name of the resource group.

<FormID>

The unique ID of your Microsoft Form.

<approveremailadres>

The email address of the approver.

<offboardingEmailAdres>

The email address for offboarding tasks.

<SenderEmailAdres>

The email address used to send notifications.

