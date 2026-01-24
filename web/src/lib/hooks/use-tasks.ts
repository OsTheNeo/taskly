"use client";

import { useState, useEffect, useCallback } from 'react';
import {
  getTasks,
  createTask,
  updateTask,
  deleteTask,
  completeTask,
  uncompleteTask,
  type TaskWithCompletion,
  type CreateTaskInput,
} from '../supabase';

interface TasksState {
  tasks: TaskWithCompletion[];
  loading: boolean;
  error: string | null;
}

export function useTasks(firebaseUid: string | null) {
  const [state, setState] = useState<TasksState>({
    tasks: [],
    loading: true,
    error: null,
  });

  // Load tasks
  const loadTasks = useCallback(async () => {
    if (!firebaseUid) {
      setState({ tasks: [], loading: false, error: null });
      return;
    }

    setState(prev => ({ ...prev, loading: true }));
    try {
      const tasks = await getTasks(firebaseUid);
      setState({ tasks, loading: false, error: null });
    } catch (error) {
      console.error('Error loading tasks:', error);
      setState({ tasks: [], loading: false, error: 'Failed to load tasks' });
    }
  }, [firebaseUid]);

  // Load on mount and when firebaseUid changes
  useEffect(() => {
    loadTasks();
  }, [loadTasks]);

  // Add task
  const addTask = useCallback(async (input: CreateTaskInput) => {
    if (!firebaseUid) return null;

    try {
      const task = await createTask(firebaseUid, input);
      if (task) {
        await loadTasks(); // Reload to get latest state
      }
      return task;
    } catch (error) {
      console.error('Error adding task:', error);
      return null;
    }
  }, [firebaseUid, loadTasks]);

  // Update task
  const editTask = useCallback(async (taskId: string, input: Partial<CreateTaskInput>) => {
    try {
      const task = await updateTask(taskId, input);
      if (task) {
        await loadTasks();
      }
      return task;
    } catch (error) {
      console.error('Error updating task:', error);
      return null;
    }
  }, [loadTasks]);

  // Remove task
  const removeTask = useCallback(async (taskId: string) => {
    try {
      const success = await deleteTask(taskId);
      if (success) {
        await loadTasks();
      }
      return success;
    } catch (error) {
      console.error('Error removing task:', error);
      return false;
    }
  }, [loadTasks]);

  // Toggle task completion
  const toggleComplete = useCallback(async (taskId: string) => {
    if (!firebaseUid) return false;

    const task = state.tasks.find(t => t.id === taskId);
    if (!task) return false;

    try {
      if (task.completion?.status === 'completed') {
        // Uncomplete
        await uncompleteTask({ taskId, firebaseUid });
      } else {
        // Complete
        await completeTask({ taskId, firebaseUid, status: 'completed' });
      }
      await loadTasks();
      return true;
    } catch (error) {
      console.error('Error toggling task:', error);
      return false;
    }
  }, [firebaseUid, state.tasks, loadTasks]);

  // Update progress for goals
  const updateProgress = useCallback(async (taskId: string, progressValue: number) => {
    if (!firebaseUid) return false;

    const task = state.tasks.find(t => t.id === taskId);
    if (!task) return false;

    try {
      const isComplete = task.progress_target ? progressValue >= task.progress_target : false;
      await completeTask({
        taskId,
        firebaseUid,
        status: isComplete ? 'completed' : 'partial',
        progressValue,
      });
      await loadTasks();
      return true;
    } catch (error) {
      console.error('Error updating progress:', error);
      return false;
    }
  }, [firebaseUid, state.tasks, loadTasks]);

  // Computed values
  const completedCount = state.tasks.filter(t => t.completion?.status === 'completed').length;
  const totalCount = state.tasks.length;
  const goals = state.tasks.filter(t => t.task_type === 'goal');
  const completedGoals = goals.filter(t => t.completion?.status === 'completed').length;

  return {
    tasks: state.tasks,
    loading: state.loading,
    error: state.error,
    completedCount,
    totalCount,
    goals,
    completedGoals,
    totalGoals: goals.length,
    refresh: loadTasks,
    addTask,
    editTask,
    removeTask,
    toggleComplete,
    updateProgress,
  };
}
