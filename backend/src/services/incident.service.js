const createIncident = async (data, reporterId) => {
    return prisma.$transaction(async (tx) => {
      // สร้าง Incident
      const incident = await tx.incident.create({
        data: {
          ...data,
          reporterId
        }
      });
  
      // Auto-create ChatRoom
      await tx.chatRoom.create({
        data: {
          incidentId: incident.id
        }
      });
  
      return incident;
    });
  };