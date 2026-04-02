#!/usr/bin/env node
/**
 * Express.js REST API - Integration Test
 * Demonstrates using Hummingbird Node.js image for web applications
 */

const express = require('express');
const app = express();
const PORT = 8080;

// Middleware
app.use(express.json());

// In-memory data store
let users = [];
let userIdCounter = 1;

// Logging middleware
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
    next();
});

// Health check
app.get('/', (req, res) => {
    res.json({
        status: 'healthy',
        service: 'Hummingbird Node.js Integration Test',
        nodeVersion: process.version,
        timestamp: new Date().toISOString()
    });
});

// Get all users
app.get('/api/users', (req, res) => {
    res.json({
        users: users,
        count: users.length
    });
});

// Get user by ID
app.get('/api/users/:id', (req, res) => {
    const user = users.find(u => u.id === parseInt(req.params.id));

    if (!user) {
        return res.status(404).json({ error: 'User not found' });
    }

    res.json(user);
});

// Create user
app.post('/api/users', (req, res) => {
    const { name, email } = req.body;

    if (!name || !email) {
        return res.status(400).json({ error: 'Name and email are required' });
    }

    const user = {
        id: userIdCounter++,
        name,
        email,
        createdAt: new Date().toISOString()
    };

    users.push(user);
    res.status(201).json(user);
});

// Update user
app.put('/api/users/:id', (req, res) => {
    const user = users.find(u => u.id === parseInt(req.params.id));

    if (!user) {
        return res.status(404).json({ error: 'User not found' });
    }

    const { name, email } = req.body;

    if (name) user.name = name;
    if (email) user.email = email;
    user.updatedAt = new Date().toISOString();

    res.json(user);
});

// Delete user
app.delete('/api/users/:id', (req, res) => {
    const userIndex = users.findIndex(u => u.id === parseInt(req.params.id));

    if (userIndex === -1) {
        return res.status(404).json({ error: 'User not found' });
    }

    users.splice(userIndex, 1);
    res.json({ message: 'User deleted' });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(500).json({ error: 'Internal server error' });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log('='.repeat(50));
    console.log('Hummingbird Node.js Integration Test');
    console.log('Express REST API Server');
    console.log('='.repeat(50));
    console.log(`Node Version: ${process.version}`);
    console.log(`Server running on http://0.0.0.0:${PORT}`);
    console.log('='.repeat(50));
});
