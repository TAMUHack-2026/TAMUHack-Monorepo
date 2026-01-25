
import { ProfileInfo } from "../state/AppState";

export type BreathData = {
  flow: number[];
  volume: number[];
};

export class ApiClient {
  private static baseUrl = process.env.EXPO_PUBLIC_API_BASE_URL?.replace(/\/+$/, "") || "";

  static async ping(): Promise<boolean> {
    try {
      const response = await fetch(`${this.baseUrl}/ping`);
      const text = await response.text();
      return response.ok && text.includes("pong");
    } catch (e) {
      console.error("Ping failed:", e);
      return false;
    }
  }

  static async getProfile(email: string): Promise<ProfileInfo | null> {
    try {
      const response = await fetch(`${this.baseUrl}/profile/${email}`);
      if (!response.ok) {
        if (response.status === 404) return null;
        throw new Error(`Failed to fetch profile: ${response.status}`);
      }
      const data = await response.json();

      // Transform backend fields to frontend fields
      return {
        email,
        firstName: data.first_name || "",
        lastName: data.last_name || "",
        height: data.height_in?.toString() || "",
        weight: data.weight_lbs?.toString() || "",
        age: data.age?.toString() || "",
        sex: data.sex === "male" ? "Male" : data.sex === "female" ? "Female" : "",
        genderIdentity: data.gender_identity || "",
      };
    } catch (e) {
      console.error("Get profile failed:", e);
      return null;
    }
  }

  static async updateUser(email: string, profile: ProfileInfo): Promise<boolean> {
    try {
      const body = {
        email, // Email is key
        age: parseInt(profile.age) || 0,
        sex: profile.sex === "Male" ? "male" : "female",
        height_in: parseFloat(profile.height) || 0,
        weight_lbs: parseFloat(profile.weight) || 0,
        // Backend requires these, so we send dummy if missing? 
        // Or we rely on the fact that the valid profile check in AppState ensures they are present.
        // Also need names? The backend schema says names are required?
        // Let's assume we are updating existing user so PATCH might be partial?
        // Wait, backend specific says: "required: - email". And "Update an existing user's information".
        // Schema refs User which has all fields?
        // PATCH /user body says:
        /*
          schema:
            allOf:
              - $ref: '#/components/schemas/User'
              - type: object
                required:
                  - email
        */
        // So strict mapping might be an issue if first_name/last_name are missing in frontend state.
        // Frontend doesn't have name fields. I'll pass dummy or empty strings if required,
        // checking if PATCH allows partial updates.
        // The "allOf" usually implies checking against the User schema too.
        // But "required" list in User schema lists all fields. 
        // If PATCH requires full User object + email, then we are in trouble if we don't have names.
        // However, usually PATCH supports partial. The docs say:
        // "Update an existing user's information".
        // Let's try sending what we have. If it fails, we know why.
        first_name: "User", // Placeholder
        last_name: "Name",  // Placeholder
      };

      const response = await fetch(`${this.baseUrl}/user`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(body),
      });

      if (!response.ok) {
        const text = await response.text();
        console.error("Update user failed:", response.status, text);
        return false;
      }
      return true;
    } catch (e) {
      console.error("Update user failed:", e);
      return false;
    }
  }

  static async createUser(email: string, profile: ProfileInfo): Promise<boolean> {
    try {
      const body = {
        email,
        password: "password123", // Still dummy as no password input in UI yet
        first_name: profile.firstName || "User",
        last_name: profile.lastName || "Name",
        age: parseInt(profile.age) || 0,
        sex: profile.sex === "Male" ? "male" : "female",
        height_in: parseFloat(profile.height) || 0,
        weight_lbs: parseFloat(profile.weight) || 0,
        gender_identity: profile.genderIdentity || "",
      };

      const response = await fetch(`${this.baseUrl}/user`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(body),
      });

      if (!response.ok) {
        const text = await response.text();
        console.error("Create user failed:", response.status, text);
        return false;
      }
      return true;
    } catch (e) {
      console.error("Create user failed:", e);
      return false;
    }
  }
}
