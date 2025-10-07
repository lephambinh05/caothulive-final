const { db } = require('./firebase-admin-config');

async function seedData() {
  try {
    console.log('🌱 Starting to seed data to Firebase...');

    // Sample YouTube Links
    const youtubeLinks = [
      {
        title: 'HACKINTOSH DUAL BOOT - macOS + Windows',
        url: 'https://www.youtube.com/watch?v=jNQXAC9IVRw',
        priority: 1,
        created_at: new Date(),
        is_active: true
      },
      {
        title: 'Video Demo 2',
        url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        priority: 2,
        created_at: new Date(),
        is_active: true
      },
      {
        title: 'Video Demo 3',
        url: 'https://www.youtube.com/watch?v=9bZkp7q19f0',
        priority: 3,
        created_at: new Date(),
        is_active: true
      }
    ];

    // Sample YouTube Channels
    const youtubeChannels = [
      {
        channel_id: 'UC123456789',
        channel_name: 'Demo Channel 1',
        channel_url: 'https://www.youtube.com/channel/UC123456789',
        avatar_url: 'https://via.placeholder.com/150/FF0000/FFFFFF?text=DC1',
        description: 'Demo channel description',
        subscriber_count: 15000,
        video_count: 250,
        created_at: new Date(),
        is_active: true
      }
    ];

    // Add YouTube Links
    console.log('📝 Adding YouTube links...');
    for (const link of youtubeLinks) {
      await db.collection('youtube_links').add(link);
      console.log(`✅ Added link: ${link.title}`);
    }

    // Add YouTube Channels
    console.log('📺 Adding YouTube channels...');
    for (const channel of youtubeChannels) {
      await db.collection('youtube_channels').add(channel);
      console.log(`✅ Added channel: ${channel.channel_name}`);
    }

    console.log('🎉 Data seeding completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding data:', error);
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  seedData();
}

module.exports = { seedData };
