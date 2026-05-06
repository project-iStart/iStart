# Collaboration & Funding Feature - Implementation Guide

## Overview
This document outlines the complete implementation of the collaboration and funding request features for the iStart application.

## Feature Workflows

### 1. Collaborator Request Workflow
1. **Collaborator** browses startup ideas
2. **Collaborator** selects an idea and views details
3. **Collaborator** clicks send collaboration message button
4. **Collaborator** fills in message in dialog and sends request
5. **Founder** receives notification of join request
6. **Founder** navigates to the idea they posted
7. **Founder** views "Join Requests" tab (existing feature, now improved)
8. **Founder** reviews pending collaborator requests with profile details
9. **Founder** approves or rejects collaboration request
10. **On Approval**: 
    - Collaborator added to startup's `teamMembers`
    - Collaborator receives approval notification
    - Collaborator appears in "Approved" tab

### 2. Investor Request Workflow
1. **Investor** browses startup ideas
2. **Investor** selects an idea and views details
3. **Investor** clicks "Request to Fund" button (money icon)
4. **Investor** fills in optional funding amount and message
5. **Investor** sends funding request
6. **Founder** receives notification of investment request
7. **Founder** navigates to the idea they posted
8. **Founder** views "Funding Requests" tab (new feature)
9. **Founder** reviews pending investor requests with:
    - Investor name, email, profile
    - Requested funding amount (if provided)
    - Investment message
10. **Founder** approves or rejects funding request
11. **On Approval**:
    - Investor added to startup's `approvedInvestors`
    - Investor receives approval notification
    - Investor can now proceed with investment

## Backend Implementation

### Database Models
**InvestmentRequest.js** - New Model
```
- investor (ref: User)
- startupIdea (ref: StartupIdea)
- fundingAmount (optional)
- message
- status (pending, approved, rejected)
- timestamps
```

**StartupIdea.js** - Updated
```
Added:
- approvedInvestors: [User IDs]
```

**JoinRequest.js** - Updated with improved validation
```
- Better error handling
- Prevents duplicate pending requests
```

### API Routes

**POST /api/investment-requests**
- Investor sends funding request
- Validates investor role
- Prevents duplicate pending requests
- Creates notification for founder

**GET /api/investment-requests/:ideaId**
- Founder views funding requests for specific startup
- Populates investor details
- Authorization check

**PUT /api/investment-requests/:id**
- Founder approves/rejects request
- Updates approvedInvestors array on approval
- Sends notification to investor

**GET /api/investment-requests/investor/my-requests**
- Investor views their own funding requests
- Tracks status across multiple startups

**Updated: GET /api/ideas/:id**
- Now populates approvedInvestors
- Investors can see they've been approved

## Frontend Implementation

### New Models
- `investment_request.dart` - InvestmentRequest model

### New Services
- `investment_request_service.dart` - API calls for investment requests

### New Providers
- `investment_request_provider.dart` - State management for investment requests

### New Screens
- `investment_request_management_screen.dart` - Founder manages investment requests
  - Tabs: Pending / Approved
  - Approve/Reject buttons
  - Shows investor details and funding amount
  
- `send_funding_request_dialog.dart` - Investor sends funding request
  - Optional funding amount field
  - Message text area
  - Input validation

### Updated Screens
- `idea_detail_screen.dart`
  - Added "Request to Fund" button for investors (money icon)
  - Added "Manage Investment Requests" button for founders (trending up icon)
  - Imports new screens and dialogs

## Testing Scenarios

### Test 1: Investor sends funding request
1. Login as Investor (user2@test.com)
2. Browse ideas
3. Click on a startup posted by a founder
4. Click money icon in top right
5. Enter funding amount (e.g., 100000)
6. Enter message
7. Click "Send Request"
8. Verify success message
9. Check investor's "My Requests" tab to see pending status

### Test 2: Founder approves funding request
1. Login as Founder (founder@test.com)
2. Go to your posted startup
3. Click trending up icon
4. See pending investor request
5. Click "Approve"
6. Verify investor added to team and notification sent
7. Switch to "Approved" tab to see investor listed

### Test 3: Founder rejects funding request
1. Login as Founder
2. Navigate to funding requests
3. Click "Reject" on a pending request
4. Verify request moves to rejected status
5. Verify notification sent to investor

### Test 4: Collaborator request (existing feature)
1. Login as Collaborator (collab@test.com)
2. Click on a startup
3. Click message icon
4. Send collaboration request
5. Founder reviews and approves
6. Collaborator added to team

## API Response Examples

### Investment Request Creation
```json
{
  "_id": "65a1b2c3d4e5f6g7h8i9j0k1",
  "investor": {
    "_id": "user_id",
    "name": "John Investor",
    "email": "investor@example.com",
    "investmentFocus": "B2B SaaS"
  },
  "startupIdea": "idea_id",
  "fundingAmount": 100000,
  "message": "I'm interested in your SaaS startup...",
  "status": "pending",
  "createdAt": "2024-05-07T10:30:00Z"
}
```

### Founder's Funding Requests
```json
[
  {
    "_id": "req_id_1",
    "investor": {
      "_id": "investor_id",
      "name": "Investor Name",
      "profileImage": "url",
      "investmentFocus": "Focus Area"
    },
    "fundingAmount": 50000,
    "message": "Message from investor",
    "status": "pending"
  }
]
```

## Error Handling

- Only investors can send funding requests
- Only founders can approve/reject requests
- Prevents duplicate pending requests from same investor
- Validates funding amounts if provided
- Authorization checks on sensitive endpoints

## Notifications Sent

1. **Investor submits request**: Founder notified
2. **Founder approves request**: Investor notified with success message
3. **Founder rejects request**: Investor notified of rejection

## Integration Notes

- Uses existing authentication middleware
- Uses existing Notification system
- Uses existing notification UI components
- Follows same design patterns as join requests
- Uses same role-based access control

## Future Enhancements

1. Add investment tracking/records after approval
2. Implement actual payment integration
3. Add investor portfolio management
4. Implement follow-up messages/negotiation
5. Add investment history and analytics
