# API Endpoint Documentation

## Endpoint Consolidation Notes

### Collection Points vs Spaces

The project currently has two similar-looking endpoints:
- `/api/collection-points` - For waste collection points (SmartWaste domain)
- `/api/spaces` - For shared workspaces/meeting rooms (different domain)

**Important:** These endpoints serve **different purposes**:

#### `/api/collection-points`
- **Purpose**: Manage waste collection points for the SmartWaste application
- **Authentication**: Requires OPERATOR or ADMIN role for POST operations
- **Features**:
  - List all active collection points with filters
  - Create new collection points with address, waste types, and schedules
  - Links to Operator model in the database

#### `/api/spaces`
- **Purpose**: Appears to be for managing shared workspaces/meeting rooms
- **Authentication**: Requires AGENCY role for POST/PUT/DELETE operations
- **Features**:
  - List spaces with typology filters (MEETING_ROOMS, etc.)
  - Includes pricing, services, ratings
  - Image upload functionality
  - Full space booking options

### Recommendation

These endpoints should **NOT** be consolidated as they serve different business domains:
1. SmartWaste collection points (waste management)
2. Shared workspaces (workspace rental/booking)

If the spaces functionality is not needed for the SmartWaste project, consider:
- Removing the `/api/spaces` endpoints entirely
- Keeping only `/api/collection-points` for waste management features

### Current Implementation Status

As of the latest updates:
- ✅ Both endpoints have proper authentication
- ✅ Both endpoints have ownership verification for sensitive operations
- ✅ Business logic has been separated into service layers
- ✅ All DELETE operations return 204 No Content
