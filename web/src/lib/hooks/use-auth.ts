"use client";

import { useState, useEffect, useCallback } from 'react';
import { upsertProfile, getProfile, type Profile } from '../supabase';

interface AuthState {
  user: Profile | null;
  loading: boolean;
  error: string | null;
}

// Helper para acceder a localStorage de forma segura (SSR-safe)
const safeLocalStorage = {
  getItem: (key: string): string | null => {
    if (typeof window === 'undefined') return null;
    return localStorage.getItem(key);
  },
  setItem: (key: string, value: string): void => {
    if (typeof window === 'undefined') return;
    localStorage.setItem(key, value);
  },
  removeItem: (key: string): void => {
    if (typeof window === 'undefined') return;
    localStorage.removeItem(key);
  },
};

// Simple auth hook - en producción usarías Firebase Auth
// Por ahora usamos localStorage para demo
export function useAuth() {
  const [state, setState] = useState<AuthState>({
    user: null,
    loading: true,
    error: null,
  });

  // Load user from localStorage on mount
  useEffect(() => {
    const loadUser = async () => {
      try {
        const storedUid = safeLocalStorage.getItem('taskly_firebase_uid');
        if (storedUid) {
          const profile = await getProfile(storedUid);
          setState({ user: profile, loading: false, error: null });
        } else {
          setState({ user: null, loading: false, error: null });
        }
      } catch (error) {
        console.error('Error loading user:', error);
        setState({ user: null, loading: false, error: 'Failed to load user' });
      }
    };

    loadUser();
  }, []);

  // Demo login function
  const login = useCallback(async (email: string, displayName: string) => {
    setState(prev => ({ ...prev, loading: true, error: null }));
    try {
      // Generate a demo firebase UID
      const firebaseUid = `demo_${email.replace(/[^a-z0-9]/gi, '_')}`;

      // Save to Supabase
      const profile = await upsertProfile({
        firebaseUid,
        email,
        displayName,
      });

      if (profile) {
        safeLocalStorage.setItem('taskly_firebase_uid', firebaseUid);
        setState({ user: profile, loading: false, error: null });
        return true;
      } else {
        setState({ user: null, loading: false, error: 'Failed to create profile' });
        return false;
      }
    } catch (error) {
      console.error('Login error:', error);
      setState({ user: null, loading: false, error: 'Login failed' });
      return false;
    }
  }, []);

  // Logout function
  const logout = useCallback(() => {
    safeLocalStorage.removeItem('taskly_firebase_uid');
    setState({ user: null, loading: false, error: null });
  }, []);

  // Get the firebase UID for API calls
  const getFirebaseUid = useCallback(() => {
    return safeLocalStorage.getItem('taskly_firebase_uid');
  }, []);

  return {
    user: state.user,
    loading: state.loading,
    error: state.error,
    isAuthenticated: !!state.user,
    login,
    logout,
    getFirebaseUid,
  };
}
