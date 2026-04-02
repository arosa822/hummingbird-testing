#!/usr/bin/env python3
"""
Simple Flask REST API - Integration Test
Demonstrates using Hummingbird Python image for web applications
"""

from flask import Flask, jsonify, request
import json
import sys
from datetime import datetime

app = Flask(__name__)

# In-memory data store
tasks = []
task_id_counter = 1


@app.route('/')
def home():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "service": "Hummingbird Python Integration Test",
        "python_version": sys.version,
        "timestamp": datetime.now().isoformat()
    })


@app.route('/api/tasks', methods=['GET'])
def get_tasks():
    """Get all tasks"""
    return jsonify({
        "tasks": tasks,
        "count": len(tasks)
    })


@app.route('/api/tasks', methods=['POST'])
def create_task():
    """Create a new task"""
    global task_id_counter

    data = request.get_json()

    if not data or 'title' not in data:
        return jsonify({"error": "Title is required"}), 400

    task = {
        "id": task_id_counter,
        "title": data['title'],
        "description": data.get('description', ''),
        "completed": False,
        "created_at": datetime.now().isoformat()
    }

    tasks.append(task)
    task_id_counter += 1

    return jsonify(task), 201


@app.route('/api/tasks/<int:task_id>', methods=['GET'])
def get_task(task_id):
    """Get a specific task"""
    task = next((t for t in tasks if t['id'] == task_id), None)

    if not task:
        return jsonify({"error": "Task not found"}), 404

    return jsonify(task)


@app.route('/api/tasks/<int:task_id>', methods=['PUT'])
def update_task(task_id):
    """Update a task"""
    task = next((t for t in tasks if t['id'] == task_id), None)

    if not task:
        return jsonify({"error": "Task not found"}), 404

    data = request.get_json()

    if 'title' in data:
        task['title'] = data['title']
    if 'description' in data:
        task['description'] = data['description']
    if 'completed' in data:
        task['completed'] = data['completed']

    task['updated_at'] = datetime.now().isoformat()

    return jsonify(task)


@app.route('/api/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    """Delete a task"""
    global tasks

    task = next((t for t in tasks if t['id'] == task_id), None)

    if not task:
        return jsonify({"error": "Task not found"}), 404

    tasks = [t for t in tasks if t['id'] != task_id]

    return jsonify({"message": "Task deleted"}), 200


if __name__ == '__main__':
    print("=" * 50)
    print("Hummingbird Python Integration Test")
    print("Flask REST API Server")
    print("=" * 50)
    print(f"Python Version: {sys.version}")
    print(f"Starting server on 0.0.0.0:8080")
    print("=" * 50)

    # Run Flask app
    app.run(host='0.0.0.0', port=8080, debug=False)
